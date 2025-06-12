class UpdateOneActiveSchoolingPerStudentIndex < ActiveRecord::Migration[8.0]
  def change
    remove_index :schoolings, name: :one_active_schooling_per_student

    add_index :schoolings, :student_id,
              name: "one_active_schooling_per_student",
              unique: true,
              where: "end_date is null and removed_at is null"
  end
end
