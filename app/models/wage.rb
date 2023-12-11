# frozen_string_literal: true

class Wage < ApplicationRecord
  enum :ministry, Mef.ministries.keys

  validates :mefstat4, :ministry, :daily_rate, :yearly_cap, presence: true
  validates :daily_rate, :yearly_cap, numericality: { only_integer: true, greater_than: 0 }
end
