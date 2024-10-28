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
    previous_pfmps
      .map(&:amount)
      .compact
      .sum
  end

  def pfmps_for_mef_and_school_year
    student.pfmps
           .in_state(:completed, :validated)
           .joins(schooling: :classe)
           .where("classes.mef_id": mef.id, "classes.school_year_id": school_year.id)
  end

  def previous_pfmps
    pfmps_for_mef_and_school_year
      .before(created_at)
      .where.not(amount: nil)
  end

  def following_rebalancable_pfmps
    pfmps_for_mef_and_school_year
      .after(created_at)
      .select(&:can_be_rebalanced?)
  end
end
