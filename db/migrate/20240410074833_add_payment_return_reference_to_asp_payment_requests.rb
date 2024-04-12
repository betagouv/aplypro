# frozen_string_literal: true

class AddPaymentReturnReferenceToASPPaymentRequests < ActiveRecord::Migration[7.1]
  def change
    add_reference :asp_payment_requests, :asp_payment_return, foreign_key: true
  end
end
