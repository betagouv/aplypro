# frozen_string_literal: true

FactoryBot.define do
  factory :student do
    ine { Faker::Number.number(digits: 10) }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    birthdate { Faker::Date.birthday(min_age: 16, max_age: 20) }

    transient do
      establishment { nil }
      birth_country_code { Faker::Number.number(digits: 5) }
      address_country_code_value { Faker::Number.number(digits: 5) }
    end

    trait :asp_ready do
      with_all_asp_info
      with_french_address
    end

    trait :with_extra_info do
      with_address
      with_birthplace_info

      biological_sex { [1, 2].sample }
    end

    trait :with_all_asp_info do
      with_personal_rib
      with_extra_info
    end

    trait :with_address_info do
      with_address
    end

    trait :with_french_address do
      address_country_code_value { "99100" }

      with_address
    end

    trait :with_foreign_address do
      address_country_code_value { "99351" }

      with_address
    end

    trait :with_birthplace_info do
      birthplace_city_insee_code { Faker::Number.number(digits: 5) }
      birthplace_country_insee_code { birth_country_code }
    end

    trait :with_address do
      address_line1 { Faker::Address.street_name }
      address_line2 { Faker::Address.street_name }
      address_postal_code { Faker::Address.zip_code }
      address_city_insee_code { Faker::Number.number(digits: 5) }
      address_city { Faker::Address.city }
      address_country_code { address_country_code_value }
    end

    trait :with_rib do
      after(:create) do |student|
        create(:rib, student: student)
      end
    end

    trait :with_other_person_rib do
      after(:create) do |student|
        create(:rib, :other_person, student: student)
      end
    end

    trait :with_personal_rib do
      after(:create) do |student, evaluator|
        create(:rib, :personal, student: student,
                                establishment: evaluator.establishment || student.establishment || create(:establishment)) # rubocop:disable Layout/LineLength
      end
    end

    trait :born_in_france do
      birth_country_code { "99100" }

      with_birthplace_info
    end

    trait :born_abroad do
      birth_country_code { "11111" }

      with_birthplace_info
    end

    trait :underage do
      birthdate { Faker::Date.birthday(min_age: 16, max_age: 17) }
    end

    trait :adult do
      birthdate { Faker::Date.birthday(min_age: 18, max_age: 20) }
    end
  end
end
