# frozen_string_literal: true

class CreateJoinTableEstablishmentUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :establishment_users, id: false do |t|
      t.references :user, foreign_key: true
      t.references :granted_by, foreign_key: { to_table: :users }

      t.integer :role, null: false
    end

    add_column :establishment_users, :establishment_id, :string, null: false # rubocop:disable Rails:NotNullColumn
    add_foreign_key :establishment_users, :establishments, primary_key: "uai"
  end
end
