# frozen_string_literal: true

class AddProviderToEstablishments < ActiveRecord::Migration[7.1]
  def change
    change_table :establishments, bulk: true do |t|
      t.string :students_provider
      t.string :ministry
    end
  end
end
