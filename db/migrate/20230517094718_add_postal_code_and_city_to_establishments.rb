# frozen_string_literal: true

class AddPostalCodeAndCityToEstablishments < ActiveRecord::Migration[7.0]
  def change
    change_table :establishments, bulk: true do |t|
      t.string :postal_code
      t.string :city
    end
  end
end
