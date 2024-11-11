# frozen_string_literal: true

# Simple Ruby service to Handle complex actions on PFMPs

class PfmpManager
  class PfmpManagerError < StandardError; end
  class ExistingActivePaymentRequestError < PfmpManagerError; end
  class PfmpNotModifiableError < PfmpManagerError; end
  class PaymentRequestNotIncompleteError < PfmpManagerError; end

  attr_reader :pfmp

  def initialize(pfmp)
    @pfmp = pfmp
  end

  def update(params)
    update!(params)
    true
  rescue ActiveRecord::RecordInvalid
    false
  end

  def update!(params)
    old_day_count = pfmp.day_count
    pfmp.update!(params)

    recalculate_amounts! if params[:day_count].present? && old_day_count != params[:day_count]

    transition!
  end

  def recalculate_amounts!
    raise PfmpNotModifiableError unless pfmp.can_be_modified?

    Pfmp.transaction do
      pfmp.all_pfmps_for_mef.lock!
      pfmp.update!(amount: calculate_amount)
      rebalance_other_pfmps!
    end
  end

  def create_new_payment_request!
    raise ExistingActivePaymentRequestError if pfmp.latest_payment_request&.active?

    pfmp.payment_requests.create! if pfmp.amount.positive?
  end

  def retry_incomplete_payment_request!
    last_payment_request = pfmp.latest_payment_request

    raise PaymentRequestNotIncompleteError unless last_payment_request.in_state?(:incomplete)

    last_payment_request.mark_ready!

    !last_payment_request.in_state?(:incomplete)
  end

  def rectify_and_update_attributes!(confirmed_pfmp_params, confirmed_address_params)
    Pfmp.transaction do
      @pfmp.update!(confirmed_pfmp_params)
      @pfmp.student.update!(confirmed_address_params)
      @pfmp.rectify!
    end
  end

  def calculate_amount
    return 0 if pfmp.day_count.nil?

    [
      pfmp.day_count * pfmp.wage.daily_rate,
      pfmp.wage.yearly_cap - previously_locked_amount
    ].min
  end

  def previously_locked_amount
    other_priced_pfmps
      .map(&:amount)
      .compact
      .sum
  end

  def retry_payment_request!(reasons)
    return unless @pfmp.latest_payment_request&.eligible_for_rejected_or_unpaid_auto_retry?(reasons)

    p_r = create_new_payment_request!
    p_r.mark_ready!
  end

  private

  def other_pfmps_for_mef
    pfmp.all_pfmps_for_mef.excluding(pfmp)
  end

  def other_priced_pfmps
    other_pfmps_for_mef
      .where.not(amount: nil)
  end

  def rebalancable_pfmps
    @rebalancable_pfmps ||= other_pfmps_for_mef
                            .select(&:can_be_rebalanced?)
  end

  def rebalance_other_pfmps!
    rebalancable_pfmps.each do |rebalancable_pfmp|
      rebalancable_pfmp.update!(amount: PfmpManager.new(rebalancable_pfmp).calculate_amount)
    end
  end

  def transition!
    if pfmp.day_count.present?
      pfmp.transition_to!(:completed) if pfmp.in_state?(:pending)
    elsif pfmp.in_state?(:completed, :validated)
      pfmp.transition_to!(:pending)
    end
  end
end
