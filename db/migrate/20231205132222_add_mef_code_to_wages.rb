# frozen_string_literal: true

require_relative "../wage_seeder"

class AddMefCodeToWages < ActiveRecord::Migration[7.1]
  def up
    Wage.delete_all

    change_table :wages, bulk: true do |table|
      table.string :mef_code, null: false
      table.remove :mefstat4
    end

    WageSeeder.seed
  end

  def down
    Wage.delete_all

    change_table :wages, bulk: true do |table|
      table.remove :mef_code
      table.string :mefstat4, null: false
    end
  end
end
