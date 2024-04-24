# frozen_string_literal: true

class Exclusion < ApplicationRecord
  validates :uai, presence: true

  validates :mef_code, uniqueness: { scope: :uai }

  validate :specific_mef_or_whole_establishment

  scope :whole_establishment, -> { where(mef_code: nil) }

  def specific_mef_or_whole_establishment
    return if mef_code.blank?

    errors.add(:base, :specific_or_whole) if Exclusion.whole_establishment.excluding(self).where(uai: uai).any?
  end
end
