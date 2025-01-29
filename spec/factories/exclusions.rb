# frozen_string_literal: true

FactoryBot.define do
  factory :exclusion do
    uai { Faker::Alphanumeric.alpha(number: 8).upcase }
    mef_code { Faker::Number.number(digits: 10) }
    school_year { SchoolYear.current }

    trait :whole_establishment do
      mef_code { nil }
    end
  end
end
