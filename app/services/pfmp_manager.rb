# frozen_string_literal: true

# Simple Ruby service to Handle complex actions on PFMPs
# TODO: refactor PfmpAmountCalculator to be part of this class (requires a lot of spec changes)

class PfmpManager
  class PfmpManagerError < StandardError; end
  class ExistingActivePaymentRequestError < PfmpManagerError; end
  class PfmpNotModifiableError < PfmpManagerError; end
  class PaymentRequestNotIncompleteError < PfmpManagerError; end

  attr_reader :pfmp

  def initialize(pfmp)
    @pfmp = pfmp
  end

  def recalculate_amounts!
    raise PfmpNotModifiableError unless pfmp.can_be_modified?

    ApplicationRecord.transaction do
      pfmp.update!(amount: calculate_amount)
      rebalance_following_pfmps!
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
    ApplicationRecord.transaction do
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

  private

  def previously_locked_amount
    other_priced_pfmps
      .map(&:amount)
      .compact
      .sum
  end

  def other_pfmps_for_mef
    all_pfmps_for_mef.excluding(pfmp)
  end

  def other_priced_pfmps
    other_pfmps_for_mef
      .where.not(amount: nil)
  end

  def rebalancable_pfmps
    other_pfmps_for_mef
      .select(&:can_be_rebalanced?)
  end

  def all_pfmps_for_mef
    pfmp.student.pfmps
        .in_state(:completed, :validated)
        .joins(schooling: :classe)
        .where("classes.mef_id": pfmp.mef.id, "classes.school_year_id": pfmp.school_year.id)
  end

  def rebalance_following_pfmps!
    rebalancable_pfmps.each do |pfmp|
      pfmp.update!(amount: calculate_amount)
    end
  end
end
