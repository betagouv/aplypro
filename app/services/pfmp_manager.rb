# frozen_string_literal: true

# Simple Ruby service to Handle complex actions on PFMPs
# TODO: refactor PfmpAmountCalculator to be part of this class (requires a lot of spec changes)

class PfmpManager
  class PreviousActivePaymentRequestError < StandardError
  end

  class PfmpNotModifiableError < StandardError
  end

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

  def start_new_payment_request!
    raise PreviousActivePaymentRequestError if pfmp.payment_requests.active.any?

    pfmp.payment_requests.create! if pfmp.amount.positive?
  end

  private

  def rebalance_following_pfmps!
    pfmp.following_modifiable_pfmps.each do |following_pfmp|
      following_pfmp.update!(amount: following_pfmp.calculate_amount)
    end
  end
end
