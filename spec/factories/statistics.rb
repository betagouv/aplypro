# frozen_string_literal: true

FactoryBot.define do
  factory :statistics do
    school_year

    bop { nil }
    academy_code { nil }
    academy_label { nil }
    establishment_uai { nil }
    establishment_name { nil }

    trait :global

    trait :bop do
      bop { "ENPU" }
    end

    trait :establishment do
      establishment_uai { Faker::Base.regexify("^[0-9]{7}[A-Z]$") }
      establishment_name { Faker::Educator.secondary_school }
    end

    trait :academy do
      bop { "ENPU" }
      academy_code { "10" }
      academy_label { "Marseille" }
    end
  end
end
