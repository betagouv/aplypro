# frozen_string_literal: true

class AddCommuneCodeToEstablishments < ActiveRecord::Migration[7.1]
  def change
    add_column :establishments, :commune_code, :string
  end
end
