# frozen_string_literal: true

# Simple Ruby service to Handle complex actions on PFMPs
# TODO: refactor PfmpAmountCalculator to be part of this class (requires a lot of spec changes)

class PfmpManager
  attr_reader :pfmp

  def initialize(pfmp)
    @pfmp = pfmp
  end

  def recalculate_amounts!
    raise "A PFMP paid or in the process of being paid cannot have its amount recalculated" unless pfmp.can_be_modified?

    ApplicationRecord.transaction do
      pfmp.update!(amount: pfmp.calculate_amount)
      rebalance_following_pfmps!
    end
  end

  def reset_payment_request!
    pfmp.payment_requests.create! if pfmp.amount.positive?
  end

  private

  def rebalance_following_pfmps!
    pfmp.following_modifiable_pfmps.each do |following_pfmp|
      following_pfmp.update!(amount: following_pfmp.calculate_amount)
    end
  end
end
