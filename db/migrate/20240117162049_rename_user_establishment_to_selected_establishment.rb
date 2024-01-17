# frozen_string_literal: true

class RenameUserEstablishmentToSelectedEstablishment < ActiveRecord::Migration[7.1]
  def change
    rename_column(:users, :establishment_id, :selected_establishment_id)
  end
end
