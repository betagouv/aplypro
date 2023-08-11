# frozen_string_literal: true

class AddDayCountToPfmps < ActiveRecord::Migration[7.0]
  def change
    add_column :pfmps, :day_count, :integer
  end
end
