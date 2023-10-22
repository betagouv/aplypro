# frozen_string_literal: true

class CreateSchoolings < ActiveRecord::Migration[7.0]
  def change
    create_table(:schoolings) do |t|
      t.references :student, null: false, foreign_key: true
      t.references :classe, null: false, foreign_key: true
      t.date :start_date
      t.date :end_date

      t.timestamps
    end

    change_table(:pfmps) do |t|
      t.references :schooling, foreign_key: true, null: false
    end

    change_table(:students) do |t|
      t.references :current_schooling, foreign_key: { to_table: :schoolings }
    end
  end
end
