# frozen_string_literal: true

class AddAddressToStudents < ActiveRecord::Migration[7.1]
  def change
    change_table :students, bulk: true do |t|
      t.string :address_line1
      t.string :address_line2
      t.string :postal_code
      t.string :city_insee_code
      t.string :city
      t.string :country_code
    end
  end
end
