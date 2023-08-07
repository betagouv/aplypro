# frozen_string_literal: true

class AddBirthdateToStudents < ActiveRecord::Migration[7.0]
  def change
    add_column :students, :birthdate, :date, null: false # rubocop:disable Rails/NotNullColumn
  end
end
