# frozen_string_literal: true

class RemoveCurrentSchoolingIdFromStudents < ActiveRecord::Migration[7.1]
  def up
    remove_reference :students, :current_schooling, foreign_key: { column: "current_schooling_id" }

    add_index :schoolings, :student_id, name: :one_active_schooling_per_student, unique: true, where: "end_date is null"
    add_index :schoolings, %i[student_id classe_id], name: :one_schooling_per_class_student, unique: true
  end

  def down
    add_reference :students, :current_schooling, foreign_key: { to_table: :schoolings }

    remove_index :schoolings, name: :one_active_schooling_per_student
    remove_index :schoolings, name: :one_schooling_per_class_student
  end
end
