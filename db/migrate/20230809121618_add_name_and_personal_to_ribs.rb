# frozen_string_literal: true

class AddNameAndPersonalToRibs < ActiveRecord::Migration[7.0]
  def change
    change_table :ribs, bulk: true do |t|
      t.name :string, null: false
      t.personal :boolean, default: false, null: false
    end
  end
end
