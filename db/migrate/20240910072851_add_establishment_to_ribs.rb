class AddEstablishmentToRibs < ActiveRecord::Migration[7.2]
  def change
    add_reference :ribs, :establishment, foreign_key: true
  end
end
