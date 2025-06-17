class UpdateOneActiveSchoolingPerStudentIndex < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def up
    add_index :schoolings, :student_id,
              name: "one_active_schooling_per_student_new",
              unique: true,
              where: "end_date IS NULL AND removed_at IS NULL",
              algorithm: :concurrently

    remove_index :schoolings, name: :one_active_schooling_per_student

    rename_index :schoolings, :one_active_schooling_per_student_new, :one_active_schooling_per_student
  end

  def down
    remove_index :schoolings, name: :one_active_schooling_per_student

    add_index :schoolings, :student_id,
              name: "one_active_schooling_per_student",
              unique: true,
              where: "end_date IS NULL",
              algorithm: :concurrently
  end
end
