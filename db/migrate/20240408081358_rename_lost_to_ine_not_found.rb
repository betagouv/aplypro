# frozen_string_literal: true

class RenameLostToIneNotFound < ActiveRecord::Migration[7.1]
  def change
    rename_column :students, :lost, :ine_not_found
  end
end
