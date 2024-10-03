# frozen_string_literal: true

FactoryBot.define do
  factory :rib do
    student
    iban { Faker::Bank.iban(country_code: "fr") }
    bic { Faker::Bank.swift_bic }
    archived_at { nil }
    name { Faker::Name.name }
    owner_type { %i[personal other_person moral_person mandate].sample }

    trait :outside_sepa do
      iban { Faker::Bank.iban(country_code: "sa") }
    end

    after(:build) do |rib|
      rib.establishment = (rib.establishment.presence || rib.student.establishment.presence || create(:establishment))
    end
  end
end
