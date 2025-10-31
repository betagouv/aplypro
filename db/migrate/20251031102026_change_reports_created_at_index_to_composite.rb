# frozen_string_literal: true

class ChangeReportsCreatedAtIndexToComposite < ActiveRecord::Migration[8.0]
  def change
    remove_index :reports, :created_at
    add_index :reports, [:created_at, :school_year_id], unique: true
  end
end
