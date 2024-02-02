# frozen_string_literal: true

FactoryBot.define do
  factory :wage do
    daily_rate { 1 }
    yearly_cap { 100 }
    mefstat4 { 123 }
    ministry { :menj }
  end
end
