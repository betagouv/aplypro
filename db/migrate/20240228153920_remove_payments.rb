# frozen_string_literal: true

class RemovePayments < ActiveRecord::Migration[7.1]
  class Payment < ApplicationRecord
    belongs_to :pfmp

    has_many :payment_requests, class_name: "ASP::PaymentRequest", dependent: :nullify
  end

  def backport_payment_amounts!
    Payment.joins(:pfmp).find_in_batches.with_index do |payments, index|
      Rails.logger.debug { "Processing batch #{index}..." }

      pfmps = payments.map do |payment|
        payment.pfmp.tap { |pfmp| pfmp.amount = payment.amount }
      end.uniq

      Pfmp.upsert_all(pfmps.map(&:attributes), update_only: [:amount]) # rubocop:disable Rails/SkipsModelValidations
    end
  end

  def rewire_payment_requests!
    Payment.joins(:pfmp, :payment_requests).find_each do |payment|
      payment.payment_requests.update_all(pfmp_id: payment.pfmp.id) # rubocop:disable Rails/SkipsModelValidations
    end
  end

  def up
    add_column :pfmps, :amount, :integer
    add_reference :asp_payment_requests, :pfmp, foreign_key: true

    backport_payment_amounts!
    rewire_payment_requests!

    remove_reference :asp_payment_requests, :payment
    drop_table :payments
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
