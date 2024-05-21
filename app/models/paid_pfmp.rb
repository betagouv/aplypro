# frozen_string_literal: true

class PaidPfmp < ApplicationRecord
  scope :paid, -> { where.not(paid_at: nil) }

  def self.refresh
    Scenic.database.refresh_materialized_view(table_name, concurrently: false, cascade: false)
  end

  def self.populated?
    Scenic.database.populated?(table_name)
  end
end
