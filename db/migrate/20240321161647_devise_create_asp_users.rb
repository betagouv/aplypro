# frozen_string_literal: true

class DeviseCreateASPUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :asp_users do |t|
      t.string :email, null: false
      t.string :name, null: false
      t.string :provider, null: false
      t.string :uid, null: false

      t.timestamps null: false
    end

    # add_index :asp_users, :email, unique: true
    add_index :asp_users, :uid, unique: true
  end
end
