class RenameRemovedAtForSchooling < ActiveRecord::Migration[8.0]
  def change
    rename_column :schoolings, :removed_at, :hidden_at
  end
end
