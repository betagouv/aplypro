# frozen_string_literal: true

class AddPrimaryKeyToEstablishmentUserRoles < ActiveRecord::Migration[7.1]
  def change
    change_table :establishment_user_roles do |t|
      t.column :id, :primary_key
    end
  end
end
