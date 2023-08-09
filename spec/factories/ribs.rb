# frozen_string_literal: true

FactoryBot.define do
  factory :rib do
    student
    iban { Faker::Bank.iban(country_code: "fr") }
    bic { Faker::Bank.swift_bic }
    archived_at { nil }
    name { Faker::Name.name }
    personal { Faker::Boolean.boolean }
  end
end
