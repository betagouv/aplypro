class AddSchoolYearToReports < ActiveRecord::Migration[8.0]
  def change
    add_reference :reports, :school_year, null: true, foreign_key: true
  end
end
