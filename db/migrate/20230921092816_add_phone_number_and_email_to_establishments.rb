# frozen_string_literal: true

class AddPhoneNumberAndEmailToEstablishments < ActiveRecord::Migration[7.0]
  def change
    change_table :establishments, bulk: true do |t|
      t.column :telephone, :string
      t.column :email, :string
    end
  end
end
