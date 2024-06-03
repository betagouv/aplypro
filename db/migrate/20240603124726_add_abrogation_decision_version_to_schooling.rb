# frozen_string_literal: true

class AddAbrogationDecisionVersionToSchooling < ActiveRecord::Migration[7.1]
  def change
    add_column :schoolings, :abrogation_decision_version, :integer, default: 0
  end
end
