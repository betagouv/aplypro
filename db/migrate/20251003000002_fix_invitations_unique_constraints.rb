# frozen_string_literal: true

class FixInvitationsUniqueConstraints < ActiveRecord::Migration[7.2]
  def change
    remove_index :invitations, name: "index_invitations_on_establishment_id_and_email"

    add_index :invitations, [:establishment_id, :email],
              unique: true,
              where: "type = 'EstablishmentInvitation'",
              name: "index_establishment_invitations_on_establishment_and_email"

    add_index :invitations, :email,
              unique: true,
              where: "type = 'AcademicInvitation'",
              name: "index_academic_invitations_on_email"
  end
end
