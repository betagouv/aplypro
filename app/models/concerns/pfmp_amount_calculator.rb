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
    previous_pfmps_for_mef
      .map(&:amount)
      .compact
      .sum
  end

  def previous_pfmps_for_mef
    student
      .pfmps
      .in_state(:completed, :validated)
      .before(created_at)
      .where.not(amount: nil)
      .joins(schooling: :classe)
      .where("classe.mef_id": mef.id, "classe.start_year": Aplypro::SCHOOL_YEAR)
  end

  def following_modifiable_pfmps_for_mef
    student
      .pfmps
      .in_state(:completed, :validated)
      .after(created_at)
      .joins(schooling: :classe)
      .where("classe.mef_id": mef.id, "classe.start_year": Aplypro::SCHOOL_YEAR)
      .select(&:can_be_modified?)
  end
end
