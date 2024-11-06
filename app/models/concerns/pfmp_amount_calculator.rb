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
    all_pfmps_for_mef.excluding(self)
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
    student.pfmps
           .joins(schooling: :classe)
           .where("classes.mef_id": mef.id, "classes.school_year_id": school_year.id)
  end
end
