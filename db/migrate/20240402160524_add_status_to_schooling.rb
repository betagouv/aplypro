# frozen_string_literal: true

class AddStatusToSchooling < ActiveRecord::Migration[7.1]
  def change
    add_column :schoolings, :status, :integer
  end
end
