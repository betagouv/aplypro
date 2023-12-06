# frozen_string_literal: true

class Wage < ApplicationRecord
  belongs_to :mef

  validates :daily_rate, :yearly_cap, presence: true
  validates :daily_rate, :yearly_cap, numericality: { only_integer: true, greater_than: 0 }
end
