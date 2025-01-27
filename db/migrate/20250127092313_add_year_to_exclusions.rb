# frozen_string_literal: true

class AddYearToExclusions < ActiveRecord::Migration[8.0]
  def change
    add_column :exclusions, :year, :int, default: nil

    remove_index :exclusions, %i[uai mef_code]
    add_index :exclusions, %i[uai mef_code year], unique: true
  end
end
