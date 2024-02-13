# frozen_string_literal: true

class DeletePaymentTransitions < ActiveRecord::Migration[7.1]
  def change
    drop_table :payment_transitions
  end
end
