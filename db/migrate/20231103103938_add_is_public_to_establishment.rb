# frozen_string_literal: true

class AddIsPublicToEstablishment < ActiveRecord::Migration[7.1]
  def change
    add_column :establishments, :private_contract_type_code, :string
  end
end
