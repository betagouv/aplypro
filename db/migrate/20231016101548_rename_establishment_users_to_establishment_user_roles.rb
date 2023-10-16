# frozen_string_literal: true

class RenameEstablishmentUsersToEstablishmentUserRoles < ActiveRecord::Migration[7.1]
  def change
    rename_table :establishment_users, :establishment_user_roles
  end
end
