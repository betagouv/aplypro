# frozen_string_literal: true

class CreateInvitations < ActiveRecord::Migration[7.1]
  def change
    create_table :invitations do |t|
      t.references :user, null: false, foreign_key: true

      t.string :email, null: false

      t.timestamps
    end

    add_column :invitations, :establishment_id, :string, null: false # rubocop:disable Rails:NotNullColumn
    add_foreign_key :invitations, :establishments, primary_key: "uai"

    add_index :invitations, %i[establishment_id email], unique: true
  end
end
