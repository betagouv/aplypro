# frozen_string_literal: true

# Simple Ruby service to Handle complex actions on PFMPs

class PfmpManager
  class PfmpManagerError < StandardError; end
  class ExistingActivePaymentRequestError < PfmpManagerError; end
  class PaidPfmpError < PfmpManagerError; end
  class PfmpNotModifiableError < PfmpManagerError; end
  class PaymentRequestNotIncompleteError < PfmpManagerError; end
  class RectificationError < PfmpManagerError; end
  class RectificationAmountThresholdNotReachedError < RectificationError; end
  class RectificationAmountZeroError < RectificationError; end

  EXCESS_AMOUNT_RECTIFICATION_THRESHOLD = 30

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
    params = params.to_h.with_indifferent_access

    Pfmp.transaction do
      pfmp.schooling&.lock! # prevent race condition using pessimistic locking (blocks r+w)

      pfmp.update!(params)
      recalculate_amounts! if params[:day_count].present?
      transition!
    end
  end

  def create_new_payment_request!
    raise ExistingActivePaymentRequestError if pfmp.latest_payment_request&.active?
    raise PaidPfmpError if pfmp.paid? && !pfmp.rectified?

    pfmp.payment_requests.create! if pfmp.payable?
  end

  def retry_incomplete_payment_request!
    last_payment_request = pfmp.latest_payment_request

    raise PaymentRequestNotIncompleteError unless last_payment_request.in_state?(:incomplete)

    last_payment_request.mark_ready!

    !last_payment_request.in_state?(:incomplete)
  end

  def rectify_and_update_attributes!(confirmed_pfmp_params, confirmed_address_params)
    Pfmp.transaction do
      paid_amount = pfmp.amount
      pfmp.rectify!
      update!(confirmed_pfmp_params)
      correct_amount = pfmp.reload.amount
      check_rectification_delta(paid_amount - correct_amount)
      pfmp.student.update!(confirmed_address_params)
    end
  end

  def previously_locked_amount(pfmp)
    other_priced_pfmps(pfmp)
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

  def calculate_amount(target_pfmp)
    return 0 if target_pfmp.day_count.nil?

    [
      target_pfmp.day_count * target_pfmp.wage.daily_rate,
      target_pfmp.wage.yearly_cap - previously_locked_amount(target_pfmp)
    ].min
  end

  def recalculate_amounts!
    raise PfmpNotModifiableError unless pfmp.can_be_modified?

    pfmp.update!(amount: calculate_amount(pfmp))
    rebalance_other_pfmps!
  end

  def other_pfmps_for_mef(excluded_pfmp)
    pfmp.all_pfmps_for_mef.excluding(excluded_pfmp)
  end

  def other_priced_pfmps(pfmp)
    other_pfmps_for_mef(pfmp)
      .where.not(amount: nil)
  end

  def rebalancable_pfmps
    @rebalancable_pfmps ||= other_pfmps_for_mef(pfmp)
                            .select(&:can_be_rebalanced?)
  end

  def rebalance_other_pfmps!
    rebalancable_pfmps.each do |rebalancable_pfmp|
      rebalancable_pfmp.update!(amount: calculate_amount(rebalancable_pfmp))
    end
  end

  def transition!
    if pfmp.day_count.present?
      pfmp.transition_to!(:completed) if pfmp.in_state?(:pending)
    elsif pfmp.in_state?(:completed, :validated)
      pfmp.transition_to!(:pending)
    end
  end

  def check_rectification_delta(delta)
    if delta.positive? && delta <= EXCESS_AMOUNT_RECTIFICATION_THRESHOLD
      raise RectificationAmountThresholdNotReachedError
    end

    raise RectificationAmountZeroError if delta.zero?
  end
end
