# frozen_string_literal: true

class AddASPPaymentReturns < ActiveRecord::Migration[7.1]
  def change
    create_table :asp_payment_returns do |t|
      t.string :filename, null: false

      t.timestamps

      t.index :filename, unique: true
    end
  end
end
