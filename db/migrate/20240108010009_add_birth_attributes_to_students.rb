# frozen_string_literal: true

class AddBirthAttributesToStudents < ActiveRecord::Migration[7.1]
  def change
    change_table :students, bulk: true do |t|
      t.string :birthplace_city_insee_code
      t.string :birthplace_country_insee_code
    end
  end
end
