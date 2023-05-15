# frozen_string_literal: true

FactoryBot.define do
  factory :establishment do
    uai { Faker::Alphanumeric.alpha }
    name { Faker::Educator.secondary_school }
    denomination { "LYCEE GENERAL ET TECHNOLOGIQUE" }
    nature { Faker::Number.between(from: 300, to: 399) }
  end
end
