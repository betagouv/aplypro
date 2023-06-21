# frozen_string_literal: true

class CreateRibs < ActiveRecord::Migration[7.0]
  def change
    create_table :ribs do |t|
      t.string :iban
      t.string :bic
      t.timestamp :archived_at

      t.timestamps
    end

    add_column :ribs, :student_id, :string, null: false # rubocop:disable Rails/NotNullColumn
    add_foreign_key :ribs, :students, primary_key: "ine"
  end
end
