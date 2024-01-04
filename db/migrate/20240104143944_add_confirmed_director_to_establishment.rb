# frozen_string_literal: true

class AddConfirmedDirectorToEstablishment < ActiveRecord::Migration[7.1]
  def change
    add_reference :establishments, :confirmed_director, foreign_key: { to_table: :users }
  end
end
