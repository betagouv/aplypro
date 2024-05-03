# frozen_string_literal: true

class Exclusion < ApplicationRecord
  validates :uai, presence: true

  validates :mef_code, uniqueness: { scope: :uai }

  validate :specific_mef_or_whole_establishment

  scope :whole_establishment, -> { where(mef_code: nil) }

  class << self
    def outside_contract?(uai, mef_code)
      exists?(uai: uai, mef_code: mef_code)
    end

    def establishment_excluded?(uai)
      whole_establishment.exists?(uai: uai)
    end

    def excluded?(uai, mef_code)
      establishment_excluded?(uai) || outside_contract?(uai, mef_code)
    end
  end

  def specific_mef_or_whole_establishment
    return if mef_code.blank?

    if Exclusion.whole_establishment.excluding(self).where(uai: uai).any? # rubocop:disable Style/GuardClause
      errors.add(:base, :specific_mef_or_whole_establishment)
    end
  end
end
