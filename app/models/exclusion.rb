# frozen_string_literal: true

class Exclusion < ApplicationRecord
  belongs_to :school_year, optional: true

  validates :uai, presence: true, uniqueness: { scope: %i[mef_code school_year_id] }

  validate :specific_mef_or_whole_establishment

  scope :whole_establishment, -> { where(mef_code: nil) }
  scope :outside_contract, -> { where.not(mef_code: nil) }

  class << self
    def outside_contract?(uai, mef_code, school_year)
      exists?(uai:, mef_code:, school_year:)
    end

    def establishment_excluded?(uai, school_year = nil)
      whole_establishment.exists?(uai:, school_year:)
    end

    def excluded?(uai, mef_code, school_year)
      establishment_excluded?(uai, school_year) || outside_contract?(uai, mef_code, school_year)
    end
  end

  def specific_mef_or_whole_establishment
    return if mef_code.blank?

    if Exclusion.whole_establishment.excluding(self).where(uai: uai).any? # rubocop:disable Style/GuardClause
      errors.add(:base, :specific_mef_or_whole_establishment)
    end
  end
end
