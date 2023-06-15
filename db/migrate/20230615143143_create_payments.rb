# frozen_string_literal: true

class CreatePayments < ActiveRecord::Migration[7.0]
  def change
    create_table :payments do |t|
      t.references :pfmp, null: false, foreign_key: true
      t.float :amount

      t.timestamps
    end
  end
end
