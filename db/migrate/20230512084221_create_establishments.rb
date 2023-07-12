# frozen_string_literal: true

class CreateEstablishments < ActiveRecord::Migration[7.0]
  def change
    create_table :establishments, id: false do |t|
      t.string :uai, primary_key: true, null: false
      t.string :name
      t.string :denomination

      t.timestamps
    end

    add_index :establishments, :uai, unique: true
  end
end
