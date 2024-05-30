# frozen_string_literal: true

class AddRibFieldToASPPaymentResquestTable < ActiveRecord::Migration[7.1]
  def change
    add_column :asp_payment_requests, :rib_id, :integer
    add_foreign_key :asp_payment_requests, :ribs, column: :rib_id
  end
end
