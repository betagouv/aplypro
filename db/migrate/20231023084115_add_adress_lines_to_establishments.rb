# frozen_string_literal: true

class AddAdressLinesToEstablishments < ActiveRecord::Migration[7.1]
  def change
    change_table :establishments, bulk: true do |t|
      t.string :address_line1
      t.string :address_line2
    end
  end
end
