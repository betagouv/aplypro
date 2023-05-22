# frozen_string_literal: true

class AddEstablishmentIdToPrincipals < ActiveRecord::Migration[7.0]
  def change
    add_column :principals, :establishment_id, :string, null: false
    add_foreign_key :principals, :establishments, primary_key: "uai"
  end
end
