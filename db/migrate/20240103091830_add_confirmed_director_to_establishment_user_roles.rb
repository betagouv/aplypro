# frozen_string_literal: true

class AddConfirmedDirectorToEstablishmentUserRoles < ActiveRecord::Migration[7.1]
  def change
    add_column :establishment_user_roles, :confirmed_director, :boolean, null: false, default: false
  end
end
