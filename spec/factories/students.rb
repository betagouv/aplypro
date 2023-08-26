# frozen_string_literal: true

FactoryBot.define do
  factory :student do
    ine { Faker::Number.number(digits: 10) }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    birthdate { Faker::Date.birthday(min_age: 16, max_age: 20) }
  end
end
