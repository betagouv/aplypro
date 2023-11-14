# frozen_string_literal: true

class RemoveCurrentSchoolingIdFromStudents < ActiveRecord::Migration[7.1]
  def up
    remove_reference :students, :current_schooling, foreign_key: { column: "current_schooling_id" }

    execute <<~SQL.squish
      CREATE UNIQUE INDEX one_active_schooling_per_student
      ON schoolings(student_id, end_date)
      NULLS NOT DISTINCT
      WHERE (end_date IS NULL)
    SQL
  end

  def down
    add_reference :students, :current_schooling, foreign_key: { to_table: :schoolings }

    execute "DROP INDEX one_active_schooling_per_student"
  end
end
