# frozen_string_literal: true

class CreateEstablishments < ActiveRecord::Migration[7.0]
  def change
    create_table :establishments, id: false do |t|
      t.string :uai, primary_key: true, null: false
      t.string :name, null: false
      t.string :denomination, null: false
      t.string :nature, null: false

      t.timestamps
    end

    add_index :establishments, :uai, unique: true
  end
end
