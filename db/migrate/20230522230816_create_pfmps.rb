# frozen_string_literal: true

class CreatePfmps < ActiveRecord::Migration[7.0]
  def change
    create_table :pfmps do |t|
      t.date :start_date
      t.date :end_date
      t.timestamps
    end
  end
end
