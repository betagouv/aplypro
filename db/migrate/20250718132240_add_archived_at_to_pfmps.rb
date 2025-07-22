class AddArchivedAtToPfmps < ActiveRecord::Migration[8.0]
  def change
    add_column :pfmps, :archived_at, :timestamp
  end
end
