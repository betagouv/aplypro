# frozen_string_literal: true

class DeletePaymentTransitions < ActiveRecord::Migration[7.1]
  def up
    drop_table :payment_transitions
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
