# frozen_string_literal: true

class CreateASPPaymentRequests < ActiveRecord::Migration[7.1]
  def change
    create_table :asp_payment_requests do |t|
      t.references :asp_request, null: false, foreign_key: true
      t.references :payment, null: false, foreign_key: true

      t.timestamps
    end
  end
end
