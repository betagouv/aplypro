class RemoveInvalidPfmpsCompositeIndex < ActiveRecord::Migration[8.0]
  def up
    execute "DROP INDEX IF EXISTS index_pfmps_on_schooling_id_and_id;"
  end

  def down
  end
end
