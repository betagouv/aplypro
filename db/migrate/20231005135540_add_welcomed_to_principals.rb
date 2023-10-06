# frozen_string_literal: true

class AddWelcomedToPrincipals < ActiveRecord::Migration[7.1]
  def change
    add_column :principals, :welcomed, :boolean, default: false, null: false
  end
end
