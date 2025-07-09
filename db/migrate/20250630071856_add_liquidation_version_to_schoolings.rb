class AddLiquidationVersionToSchoolings < ActiveRecord::Migration[8.0]
  def change
    add_column :schoolings, :liquidation_version, :integer, default: 0
  end
end
