class AddMoreIndexes < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def change
    add_index :asp_payment_request_transitions, :to_state, algorithm: :concurrently
    add_index :pfmp_transitions, :to_state, algorithm: :concurrently
  end
end
