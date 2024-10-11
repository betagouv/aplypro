# frozen_string_literal: true

class Wage < ApplicationRecord
  UNIQUENESS_SCOPE = [:mefstat4, :ministry, :daily_rate, :yearly_cap, :school_year_id]

  belongs_to :school_year

  enum :ministry, Mef.ministries.keys

  validates :mefstat4, :ministry, :daily_rate, :yearly_cap, presence: true
  validates :daily_rate, :yearly_cap, numericality: { only_integer: true, greater_than: 0 }
  validates :mefstat4, uniqueness: { scope: UNIQUENESS_SCOPE - [:mefstat4] }
end
