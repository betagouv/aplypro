# frozen_string_literal: true

class CreateStudents < ActiveRecord::Migration[7.0]
  def change
    create_table :students do |t|
      t.string :ine, null: false
      t.string :first_name
      t.string :last_name

      t.timestamps

      t.index :ine, unique: true
    end
  end
end
