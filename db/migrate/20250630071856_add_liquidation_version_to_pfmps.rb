class AddLiquidationVersionToPfmps < ActiveRecord::Migration[8.0]
  def change
    add_column :pfmps, :liquidation_version, :integer, default: 0
  end
end
