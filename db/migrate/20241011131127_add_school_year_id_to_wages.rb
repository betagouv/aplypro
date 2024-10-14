class AddSchoolYearIdToWages < ActiveRecord::Migration[7.2]
  def change
    add_reference :wages, :school_year, foreign_key: true
  end
end
