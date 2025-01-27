# frozen_string_literal: true

class Exclusion < ApplicationRecord
  validates :uai, presence: true, uniqueness: { scope: %i[mef_code year] }

  validate :specific_mef_or_whole_establishment

  scope :whole_establishment, -> { where(mef_code: nil) }
  scope :outside_contract, -> { where.not(mef_code: nil) }

  class << self
    def outside_contract?(uai, mef_code, year = nil)
      exists?(uai:, mef_code:, year:)
    end

    def establishment_excluded?(uai, year = nil)
      whole_establishment.exists?(uai:, year:)
    end

    def excluded?(uai, mef_code, year = nil)
      establishment_excluded?(uai, year) || outside_contract?(uai, mef_code, year)
    end
  end

  def specific_mef_or_whole_establishment
    return if mef_code.blank?

    if Exclusion.whole_establishment.excluding(self).where(uai: uai).any? # rubocop:disable Style/GuardClause
      errors.add(:base, :specific_mef_or_whole_establishment)
    end
  end
end
