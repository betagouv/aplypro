# frozen_string_literal: true

class AddBiologicalSexToStudents < ActiveRecord::Migration[7.1]
  def change
    add_column :students, :biological_sex, :integer, default: 0
  end
end
