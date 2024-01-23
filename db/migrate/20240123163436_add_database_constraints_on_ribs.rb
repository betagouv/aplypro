# frozen_string_literal: true

class AddDatabaseConstraintsOnRibs < ActiveRecord::Migration[7.1]
  def change
    add_index :ribs, :student_id, name: :one_active_rib_per_student, unique: true, where: "archived_at is null"
  end
end
