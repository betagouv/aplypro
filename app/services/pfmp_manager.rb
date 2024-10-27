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
      pfmp.update!(amount: pfmp.calculate_amount)
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

  private

  def rebalance_following_pfmps!
    pfmp.following_rebalancable_pfmps.each do |following_pfmp|
      following_pfmp.update!(amount: following_pfmp.calculate_amount)
    end
  end
end
