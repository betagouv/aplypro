class AddEstablishmentToRibs < ActiveRecord::Migration[7.2]
  def change
    add_reference :ribs, :establishment, foreign_key: true

    # Migrate only students with a rib
    Student.where.associated(:rib).find_each do |student|
      etab = student&.establishment
      next unless etab

      student.rib.update_columns(establishment_id: etab.id)
    end
  end
end
