# frozen_string_literal: true

class AddAdministrativeNumberToPfmps < ActiveRecord::Migration[7.1]
  def change
    add_column :pfmps, :administrative_number, :string
  end
end
