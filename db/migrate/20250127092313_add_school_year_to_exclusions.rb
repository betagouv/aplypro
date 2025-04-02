# frozen_string_literal: true

class AddSchoolYearToExclusions < ActiveRecord::Migration[8.0]
  def change
    add_reference :exclusions, :school_year, foreign_key: true, null: true

    remove_index :exclusions, %i[uai mef_code]
    add_index :exclusions, %i[uai mef_code school_year_id], unique: true
  end
end
