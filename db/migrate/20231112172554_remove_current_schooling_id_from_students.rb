# frozen_string_literal: true

class RemoveCurrentSchoolingIdFromStudents < ActiveRecord::Migration[7.1]
  def change
    remove_reference :students, :current_schooling, foreign_key: { column: "current_schooling_id" }

    add_index :schoolings, %i[student_id end_date], unique: true, where: "end_date is NULL"
  end
end
