# frozen_string_literal: true

class CreateWages < ActiveRecord::Migration[7.0]
  def change
    create_table :wages do |t|
      t.integer :daily_rate, null: false
      t.string :mefstat4, null: false
      t.integer :yearly_cap, null: false

      t.timestamps
    end
  end
end
