class AddEstablishmentIdToPrincipals < ActiveRecord::Migration[7.0]
  def change
    add_reference :principals, :establishment, null: false, foreign_key: true
  end
end
