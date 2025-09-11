class CreateSchoolYearRanges < ActiveRecord::Migration[8.0]
  def change
    create_table :school_year_ranges do |t|
      t.string :academy_code, null: false
      t.references :school_year, null: false, foreign_key: true
      t.date :start_date
      t.date :end_date

      t.timestamps
    end

    add_index :school_year_ranges, [:school_year_id, :academy_code], unique: true
  end
end
