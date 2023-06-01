# frozen_string_literal: true

class CreateClasses < ActiveRecord::Migration[7.0]
  def change
    create_table :classes do |t|
      t.references :mefstat, null: false, foreign_key: true
      t.string :label

      t.timestamps
    end

    add_column :classes, :establishment_id, :string, null: false
    add_foreign_key :classes, :establishments, primary_key: "uai"
  end
end
