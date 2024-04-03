# frozen_string_literal: true

class AddLostAttributeToStudents < ActiveRecord::Migration[7.1]
  def change
    add_column :students, :lost, :boolean, null: false, default: false
  end
end
