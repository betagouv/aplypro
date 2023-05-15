# frozen_string_literal: true

class CreatePrincipals < ActiveRecord::Migration[7.0]
  def change
    create_table :principals, primary_key: %i[uid provider] do |t|
      t.string :uid, null: false
      t.string :provider, null: false

      t.string :name, null: false
      t.string :secret, null: false
      t.string :token, null: false
      t.string :email, null: false

      t.timestamps
    end
    add_index :principals, :email, unique: true
  end
end
