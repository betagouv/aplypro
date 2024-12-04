# frozen_string_literal: true

class RemoveASPFileReferenceFromStudents < ActiveRecord::Migration[7.2]
  def change
    remove_column :students, :asp_file_reference, :string
  end
end
