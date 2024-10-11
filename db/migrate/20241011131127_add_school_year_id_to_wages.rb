class AddSchoolYearIdToWages < ActiveRecord::Migration[7.2]
  def change
    add_reference :wages, :school_year, foreign_key: true
    add_index :wages, [:mefstat4, :ministry, :school_year_id], unique: true
  end
end
