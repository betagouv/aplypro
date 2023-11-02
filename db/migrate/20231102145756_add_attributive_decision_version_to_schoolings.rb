# frozen_string_literal: true

class AddAttributiveDecisionVersionToSchoolings < ActiveRecord::Migration[7.1]
  def change
    add_column :schoolings, :attributive_decision_version, :integer, default: 0
  end
end
