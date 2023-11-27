# frozen_string_literal: true

class AddAcademyToEstablishments < ActiveRecord::Migration[7.1]
  def change
    change_table :establishments, bulk: true do |table|
      table.string :academy_code
      table.string :academy_label
    end
  end
end
