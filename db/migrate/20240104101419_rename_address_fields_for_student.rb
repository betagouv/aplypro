# frozen_string_literal: true

class RenameAddressFieldsForStudent < ActiveRecord::Migration[7.1]
  def change
    change_table :students do |t|
      t.rename :postal_code, :address_postal_code
      t.rename :city_insee_code, :address_city_insee_code
      t.rename :city, :address_city
      t.rename :country_code, :address_country_code
    end
  end
end
