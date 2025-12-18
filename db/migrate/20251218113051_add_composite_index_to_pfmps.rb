# frozen_string_literal: true

class AddCompositeIndexToPfmps < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_index :pfmps, [:schooling_id, :id],
              name: "index_pfmps_on_schooling_id_and_id",
              algorithm: :concurrently
  end
end
