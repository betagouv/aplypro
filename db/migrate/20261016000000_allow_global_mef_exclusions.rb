# frozen_string_literal: true

class AllowGlobalMefExclusions < ActiveRecord::Migration[8.0]
  def change
    change_column_null :exclusions, :uai, true
  end
end
