# frozen_string_literal: true

# Handle complex actions on PFMPs

class PfmpManager
  attr_reader :pfmp

  def initialize(pfmp)
    @pfmp = pfmp
  end

  def recalculate_amounts!
    raise "A PFMP paid or in the process of being paid cannot have its amount recalculated" unless pfmp.can_be_modified?

    ActiveRecord::Base.transaction do
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
      PfmpManager.new(following_pfmp).recalculate_amounts!
    end
  end
end
