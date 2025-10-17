# frozen_string_literal: true

class AddPerformanceIndexesToAcademicQueries < ActiveRecord::Migration[8.0]
  def change
    add_index :establishments, :academy_code
    add_index :ribs, :archived_at
    add_index :schoolings, :status
  end
end
