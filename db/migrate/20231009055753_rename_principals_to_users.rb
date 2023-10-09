# frozen_string_literal: true

class RenamePrincipalsToUsers < ActiveRecord::Migration[7.1]
  def change
    rename_table :principals, :users
  end
end
