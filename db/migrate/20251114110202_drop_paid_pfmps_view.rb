class DropPaidPfmpsView < ActiveRecord::Migration[8.0]
  def change
    drop_view :paid_pfmps, materialized: true
  end
end
