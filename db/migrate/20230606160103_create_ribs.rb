# frozen_string_literal: true

class CreateRibs < ActiveRecord::Migration[7.0]
  def change
    create_table :ribs do |t|
      t.references :student, null: false, foreign_key: true
      t.string :iban
      t.string :bic
      t.timestamp :archived_at

      t.timestamps
    end
  end
end
