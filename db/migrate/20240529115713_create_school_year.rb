# frozen_string_literal: true

class CreateSchoolYear < ActiveRecord::Migration[7.1]
  def change
    create_table :school_years do |t|
      t.integer :start_year, null: false

      t.timestamps
    end

    add_index :school_years, :start_year, unique: true

    remove_column :classes, :start_year, :string
    add_reference :classes, :school_year, foreign_key: true

    school_year = SchoolYear.create(start_year: 2023)
    Classe.find_each { |c| c.update(school_year_id: school_year.id) }

    change_column_null :classes, :school_year_id, false
  end
end
