# frozen_string_literal: true

class EstablishmentInvitation < Invitation
  validates :establishment, presence: true
  validates :email, uniqueness: { scope: :establishment_id, case_sensitive: false }

  def self.model_name
    Invitation.model_name
  end
end
