class AddEstablishmentToRibs < ActiveRecord::Migration[7.2]
  def change
    add_reference :ribs, :establishment, foreign_key: true

    # Migrate only students with a rib
    execute <<-SQL
      UPDATE ribs
      SET establishment_id = establishments.id
      FROM students
      JOIN schoolings ON students.id = schoolings.student_id
      JOIN classes ON schoolings.classe_id = classes.id
      JOIN establishments ON classes.establishment_id = establishments.id
      WHERE ribs.student_id = students.id
    SQL
  end
end
