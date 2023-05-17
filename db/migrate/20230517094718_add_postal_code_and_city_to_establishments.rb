# frozen_string_literal: true

class AddPostalCodeAndCityToEstablishments < ActiveRecord::Migration[7.0]
  def change
    add_column :establishments, :postal_code, :string, bulk: true
  end
end
