# frozen_string_literal: true

class AddGeneratingAttributiveDecisionToSchoolings < ActiveRecord::Migration[7.1]
  def change
    add_column :schoolings, :generating_attributive_decision, :boolean, default: false, null: false
  end
end
