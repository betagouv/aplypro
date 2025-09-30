class UpdateExistingReportsWithSchoolYear < ActiveRecord::Migration[8.0]
  def up
    current_school_year = SchoolYear.current || SchoolYear.order(:start_year).last

    return unless current_school_year

    Report.where(school_year_id: nil).update_all(school_year_id: current_school_year.id)
  end

  def down
    Report.update_all(school_year_id: nil)
  end
end
