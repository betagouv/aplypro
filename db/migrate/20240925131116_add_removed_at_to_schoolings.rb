class AddRemovedAtToSchoolings < ActiveRecord::Migration[7.2]
  def change
    add_column :schoolings, :removed_at, :timestamp
  end
end
