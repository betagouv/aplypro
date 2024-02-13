# frozen_string_literal: true

class AddASPAttributesToModels < ActiveRecord::Migration[7.1]
  def change
    add_column :students, :asp_individu_id, :string
    add_column :schoolings, :asp_dossier_id, :string
    add_column :pfmps, :asp_prestation_dossier_id, :string
  end
end
