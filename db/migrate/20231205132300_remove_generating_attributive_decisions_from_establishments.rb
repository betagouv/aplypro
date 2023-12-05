# frozen_string_literal: true

class RemoveGeneratingAttributiveDecisionsFromEstablishments < ActiveRecord::Migration[7.1]
  def change
    remove_column :establishments, :generating_attributive_decisions, :boolean
  end
end
