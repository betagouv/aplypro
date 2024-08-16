class AddSchoolYearToMef < ActiveRecord::Migration[7.2]
  def up
    add_reference :mefs, :school_year, foreign_key: true

    current_school_year = SchoolYear.current

    if current_school_year
      execute <<-SQL
        UPDATE mefs
        SET school_year_id = #{current_school_year.id}
      SQL
    else
      puts "Warning: No current SchoolYear found. Mef records were not updated."
    end
  end

  def down
    remove_reference :mefs, :school_year
  end
end
