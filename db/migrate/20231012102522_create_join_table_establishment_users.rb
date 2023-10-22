# frozen_string_literal: true

class CreateJoinTableEstablishmentUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :establishment_users, id: false do |t|
      t.references :establishment, foreign_key: true, null: false
      t.references :user, foreign_key: true, null: false
      t.references :granted_by, foreign_key: { to_table: :users }

      t.integer :role, null: false
    end
  end
end
