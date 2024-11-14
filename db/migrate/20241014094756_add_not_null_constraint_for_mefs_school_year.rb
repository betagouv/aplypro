class AddNotNullConstraintForMefsSchoolYear < ActiveRecord::Migration[7.2]
  def change
    change_column_null(:mefs, :school_year_id, false)
  end
end
