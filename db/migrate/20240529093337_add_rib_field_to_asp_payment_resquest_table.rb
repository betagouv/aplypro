# frozen_string_literal: true

class AddRibFieldToASPPaymentResquestTable < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_reference :asp_payment_requests, :rib, index: { algorithm: :concurrently }
  end
end
