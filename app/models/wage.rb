# frozen_string_literal: true

class Wage < ApplicationRecord
  validates :daily_rate, :yearly_cap, :mef_code, presence: true
  validates :daily_rate, :yearly_cap, numericality: { only_integer: true, greater_than: 0 }
end
