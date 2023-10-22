# frozen_string_literal: true

class AddEstablishmentIdToPrincipals < ActiveRecord::Migration[7.0]
  def change
    change_table :principals do |t|
      t.references :establishment, foreign_key: true, null: false
    end
  end
end
