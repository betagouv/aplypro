class UpdateRibUniqueIndex < ActiveRecord::Migration[7.2]
  def change
    remove_index :ribs, name: "one_active_rib_per_student"

    add_index :ribs, [:student_id, :establishment_id],
              name: "one_active_rib_per_student_per_establishment",
              unique: true,
              where: "archived_at IS NULL"
  end
end
