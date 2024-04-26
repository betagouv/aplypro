# frozen_string_literal: true

class CreateExclusions < ActiveRecord::Migration[7.1]
  def change
    create_table :exclusions do |t|
      t.string :uai, null: false
      t.string :mef_code

      t.timestamps
    end

    add_index :exclusions, %i[uai mef_code], unique: true
  end
end
