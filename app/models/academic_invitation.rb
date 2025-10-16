# frozen_string_literal: true

class AcademicInvitation < Invitation
  validates :academy_codes, presence: true
  validates :email, uniqueness: { conditions: -> { where(type: "AcademicInvitation") }, case_sensitive: false }
  validate :academy_codes_must_be_valid

  def academy_codes=(value)
    super(Array(value).compact_blank)
  end

  private

  def academy_codes_must_be_valid
    return if academy_codes.blank?

    invalid_codes = academy_codes - Establishment::ACADEMY_LABELS.keys
    return if invalid_codes.empty?

    errors.add(:academy_codes, :invalid_codes, codes: invalid_codes.join(", "))
  end
end
