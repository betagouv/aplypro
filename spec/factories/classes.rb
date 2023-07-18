# frozen_string_literal: true

FactoryBot.define do
  factory :classe do
    establishment
    mef
    sequence(:label) { |n| "3EME#{n}" }
  end
end
