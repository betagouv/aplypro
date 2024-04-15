# frozen_string_literal: true

class AddNotNullConstraintForPaymentRequestsPfmp < ActiveRecord::Migration[7.1]
  def change
    change_column_null(:asp_payment_requests, :pfmp_id, false)
  end
end
