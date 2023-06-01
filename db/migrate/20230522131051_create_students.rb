# frozen_string_literal: true

class CreateStudents < ActiveRecord::Migration[7.0]
  def change
    create_table :students, id: false do |t|
      t.references :classe, null: false, foreign_key: true
      t.string :ine, primary_key: true, null: false
      t.string :first_name
      t.string :last_name

      t.timestamps
    end
  end
end
