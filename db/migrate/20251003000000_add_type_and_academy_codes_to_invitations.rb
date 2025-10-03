# frozen_string_literal: true

class AddTypeAndAcademyCodesToInvitations < ActiveRecord::Migration[7.2]
  def change
    add_column :invitations, :type, :string
    add_column :invitations, :academy_codes, :text, array: true, default: []
    add_index :invitations, :type
  end
end
