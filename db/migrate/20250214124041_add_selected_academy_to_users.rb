# frozen_string_literal: true

class AddSelectedAcademyToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :selected_academy, :string
  end
end
