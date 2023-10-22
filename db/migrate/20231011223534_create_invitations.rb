# frozen_string_literal: true

class CreateInvitations < ActiveRecord::Migration[7.1]
  def change
    create_table :invitations do |t|
      t.references :establishment, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.string :email, null: false

      t.timestamps
    end

    add_index :invitations, %i[establishment_id email], unique: true
  end
end
