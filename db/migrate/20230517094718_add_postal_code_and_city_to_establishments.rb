class AddPostalCodeAndCityToEstablishments < ActiveRecord::Migration[7.0]
  def change
    add_column :establishments, :postal_code, :string
    add_column :establishments, :city, :string
  end
end
