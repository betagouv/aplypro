# frozen_string_literal: true

class AddIndicesOnASPAttributes < ActiveRecord::Migration[7.1]
  def change
    add_index :students, :asp_individu_id, unique: true
    add_index :schoolings, :asp_dossier_id, unique: true
    add_index :pfmps, :asp_prestation_dossier_id, unique: true
  end
end
