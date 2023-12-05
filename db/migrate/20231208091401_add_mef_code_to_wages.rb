# frozen_string_literal: true

require_relative "../wage_seeder"

class AddMefCodeToWages < ActiveRecord::Migration[7.1]
  def up
    Wage.delete_all

    change_table :wages, bulk: true do |table|
      table.integer :ministry, null: false
      table.jsonb :mef_codes
    end

    WageSeeder.seed
  end

  def down
    Wage.delete_all

    change_table :wages, bulk: true do |table|
      table.remove :ministry
      table.remove :mef_codes
    end
  end
end
