# frozen_string_literal: true

class Wage < ApplicationRecord
  validates :daily_rate, :yearly_cap, :mefstat4, presence: true
  validates :daily_rate, :yearly_cap, numericality: { only_integer: true, greater_than: 0 }
end
