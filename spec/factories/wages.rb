# frozen_string_literal: true

FactoryBot.define do
  factory :wage do
    mef
    daily_rate { 1 }
    yearly_cap { 100 }
  end
end
