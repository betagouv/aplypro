# frozen_string_literal: true

class AddNameAndPersonalToRibs < ActiveRecord::Migration[7.0]
  def change
    change_table :ribs, bulk: true do |t|
      t.string :name, null: false
      t.boolean :personal, default: false, null: false
    end
  end
end
