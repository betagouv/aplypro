# frozen_string_literal: true

class AddASPRequestReferenceToPayments < ActiveRecord::Migration[7.1]
  def change
    add_reference :payments, :asp_request, foreign_key: true
  end
end
