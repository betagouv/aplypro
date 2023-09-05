# frozen_string_literal: true

class RelaxEstablishmentConstraintOnPrincipals < ActiveRecord::Migration[7.0]
  def change
    change_column_null(:principals, :establishment_id, true)
  end
end
