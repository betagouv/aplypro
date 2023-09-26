# frozen_string_literal: true

class AddYearToClasses < ActiveRecord::Migration[7.0]
  def change
    reversible do |dir|
      change_table :classes do |t|
        dir.up do
          t.string :start_year
          Classe.update_all(start_year: 2023) # rubocop:disable Rails/SkipsModelValidations
          t.change_null :start_year, false
        end

        dir.down do
          t.remove :start_year
        end
      end
    end
  end
end
