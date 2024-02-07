# frozen_string_literal: true

class AddASPFileReferenceToStudents < ActiveRecord::Migration[7.1]
  def change
    add_column :students, :asp_file_reference, :string, null: false # rubocop:disable Rails/NotNullColumn

    add_index :students, :asp_file_reference, unique: true
  end
end
