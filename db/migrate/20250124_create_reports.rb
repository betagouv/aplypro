# frozen_string_literal: true

class CreateReports < ActiveRecord::Migration[8.0]
  def change
    create_table :reports do |t|
      t.jsonb :data, null: false, default: {}
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end

    add_index :reports, :created_at, unique: true
    add_index :reports, :data, using: :gin
  end
end
