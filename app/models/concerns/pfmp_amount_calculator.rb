# frozen_string_literal: true

module PfmpAmountCalculator
  extend ActiveSupport::Concern

  def calculate_amount
    return 0 if day_count.nil?

    [
      day_count * wage.daily_rate,
      wage.yearly_cap - previously_locked_amount
    ].min
  end

  def previously_locked_amount
    other_priced_pfmps
      .map(&:amount)
      .compact
      .sum
  end

  def other_pfmps_for_mef
    pfmp.all_pfmps_for_mef.excluding(pfmp)
  end

  def other_priced_pfmps
    other_pfmps_for_mef
      .where.not(amount: nil)
  end

  def rebalancable_pfmps
    other_pfmps_for_mef
      .select(&:can_be_rebalanced?)
  end
end
