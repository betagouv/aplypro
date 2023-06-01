# frozen_string_literal: true

FactoryBot.define do
  factory :student do
    classe
    ine { Faker::Number.number(digits: 10) }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
  end
end
