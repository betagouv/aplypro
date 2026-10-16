# frozen_string_literal: true

class Exclusion < ApplicationRecord
  belongs_to :school_year, optional: true

  validates :uai, uniqueness: { scope: %i[mef_code school_year_id] }

  validate :uai_or_mef_code
  validate :specific_mef_or_whole_establishment

  scope :whole_establishment, -> { where(mef_code: nil).where.not(uai: nil) }
  scope :whole_mef, -> { where(uai: nil).where.not(mef_code: nil) }
  scope :outside_contract, -> { where.not(uai: nil).where.not(mef_code: nil) }

  class << self
    def establishment_excluded?(uai, school_year)
      whole_establishment.exists?(uai:, school_year: [nil, school_year])
    end

    def excluded?(uai, mef_code, school_year)
      exists?(uai: [nil, uai], mef_code: [nil, mef_code], school_year: [nil, school_year])
    end
  end

  def uai_or_mef_code
    errors.add(:base, :uai_or_mef_code) if uai.blank? && mef_code.blank?
  end

  def specific_mef_or_whole_establishment
    return if uai.blank? || mef_code.blank?
    return unless Exclusion.whole_establishment.excluding(self).exists?(uai: uai)

    errors.add(:base, :specific_mef_or_whole_establishment)
  end
end
