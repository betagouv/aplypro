# frozen_string_literal: true

class AddProgressIndicatorsToEstablishments < ActiveRecord::Migration[7.0]
  def change
    change_table :establishments, bulk: true do |table|
      table.boolean :fetching_students, default: false, null: false
      table.boolean :generating_attributive_decisions, default: false, null: false
    end
  end
end
