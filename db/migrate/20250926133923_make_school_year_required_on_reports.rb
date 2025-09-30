class MakeSchoolYearRequiredOnReports < ActiveRecord::Migration[8.0]
  def change
    change_column_null :reports, :school_year_id, false
  end
end
