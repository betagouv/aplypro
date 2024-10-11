class AddSchoolYearIdToWages < ActiveRecord::Migration[7.2]
  def change
    add_reference :wages, :school_year, foreign_key: true
    add_index :wages, Wage::UNIQUENESS_SCOPE, unique: true
  end
end
