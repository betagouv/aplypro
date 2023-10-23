# frozen_string_literal: true

class CreateClasses < ActiveRecord::Migration[7.0]
  def change
    create_table :classes do |t|
      t.references :establishment
      t.references :mefstat, null: false, foreign_key: true
      t.string :label

      t.timestamps
    end
  end
end
