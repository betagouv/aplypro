# frozen_string_literal: true

class RemovePayments < ActiveRecord::Migration[7.1]
  class Payment < ApplicationRecord
    belongs_to :pfmp

    has_many :payment_requests, class_name: "ASP::PaymentRequest", dependent: :nullify
  end

  def backport_payment_amounts!
    Payment.find_each do |payment|
      pfmp = payment.pfmp

      pfmp.update!(amount: payment.amount)

      payment.payment_requests.update_all(pfmp_id: pfmp) # rubocop:disable Rails/SkipsModelValidations
    end
  end

  def up
    add_column :pfmps, :amount, :integer
    add_reference :asp_payment_requests, :pfmp, foreign_key: true

    backport_payment_amounts!

    remove_reference :asp_payment_requests, :payment
    drop_table :payments
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
