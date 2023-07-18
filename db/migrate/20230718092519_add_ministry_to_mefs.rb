# frozen_string_literal: true

class AddMinistryToMefs < ActiveRecord::Migration[7.0]
  def change
    add_column :mefs, :ministry, :integer, null: false # rubocop:disable Rails/NotNullColumn
  end
end
