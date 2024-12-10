# frozen_string_literal: true

class RemoveAdministrativeNumberFromPfmps < ActiveRecord::Migration[7.2]
  def change
    remove_column :pfmps, :administrative_number, :string
  end
end
