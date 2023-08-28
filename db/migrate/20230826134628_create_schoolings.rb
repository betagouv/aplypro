# frozen_string_literal: true

class CreateSchoolings < ActiveRecord::Migration[7.0]
  def change
    create_table(:schoolings) do |t|
      t.date :start_date
      t.date :end_date
      t.references :student, type: :string, null: false
      t.references :classe, null: false, foreign_key: true

      t.timestamps
    end

    change_table(:pfmps) do |t|
      t.remove_references :student, primary_key: "ine"
      t.references :schooling, foreign_key: true, null: false
    end

    change_table(:students) do |t|
      t.remove_references :classe, null: false
      t.column :current_schooling, :bigint

      t.foreign_key :schoolings, column: :current_schooling
    end

    # we need to do this here as `t.references` doesn't let us specify
    # the different primary key name (I think).
    add_foreign_key :schoolings, :students, primary_key: "ine"
  end
end
