# frozen_string_literal: true

FactoryBot.define do
  factory :wage do
    daily_rate { 1 }
    mefstat4 { "2213" }
    yearly_cap { 100 }
  end
end
