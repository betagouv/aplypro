class AddEstablishmentToRibs < ActiveRecord::Migration[7.2]
  def change
    add_reference :ribs, :establishment, foreign_key: true

    Student.find_each { |student| student.ribs.last.update!(establishment: student.current_schooling.establishment) }
  end
end
