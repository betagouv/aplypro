# frozen_string_literal: true

class CreateASPPaymentRequestTransitions < ActiveRecord::Migration[7.1]
  def change
    create_table :asp_payment_request_transitions do |t|
      t.string :to_state, null: false
      t.text :metadata, default: "{}"
      t.integer :sort_key, null: false
      t.integer :asp_payment_request_id, null: false
      t.boolean :most_recent, null: false

      # If you decide not to include an updated timestamp column in your transition
      # table, you'll need to configure the `updated_timestamp_column` setting in your
      # migration class.
      t.timestamps null: false
    end

    # Foreign keys are optional, but highly recommended
    add_foreign_key :asp_payment_request_transitions, :asp_payment_requests

    add_index(:asp_payment_request_transitions,
              %i[asp_payment_request_id sort_key],
              unique: true,
              name: "index_asp_payment_request_transitions_parent_sort")
    add_index(:asp_payment_request_transitions,
              %i[asp_payment_request_id most_recent],
              unique: true,
              where: "most_recent",
              name: "index_asp_payment_request_transitions_parent_most_recent")
  end
end
