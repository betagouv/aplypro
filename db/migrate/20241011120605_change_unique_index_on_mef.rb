class ChangeUniqueIndexOnMef < ActiveRecord::Migration[7.2]
  def change
    remove_index :mefs, name: "index_mefs_on_code"

    add_index :mefs, [:code, :school_year_id],
              name: "index_mefs_on_code_and_school_year",
              unique: true
  end
end
