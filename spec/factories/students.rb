# frozen_string_literal: true

FactoryBot.define do
  factory :student do
    ine { Faker::Number.number(digits: 10) }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    birthdate { Faker::Date.birthday(min_age: 16, max_age: 20) }

    trait :with_address do
      address_line1 { Faker::Address.street_name }
      address_line2 { Faker::Address.street_name }
      postal_code { Faker::Address.zip_code }
      city_insee_code { Faker::Number.digit }
      city { Faker::Address.city }
      country_code { Faker::Number.digit }
    end
  end
end
