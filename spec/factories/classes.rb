# frozen_string_literal: true

FactoryBot.define do
  factory :classe do
    establishment
    mef
    sequence(:label) { |n| "3EME#{n}" }
    start_year { 2023 }
  end
end
