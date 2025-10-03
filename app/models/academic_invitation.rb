# frozen_string_literal: true

class AcademicInvitation < Invitation
  validates :academy_codes, presence: true
  validates :email, uniqueness: { conditions: -> { where(type: "AcademicInvitation") }, case_sensitive: false }

  def academy_codes=(value)
    super(Array(value).compact_blank)
  end
end
