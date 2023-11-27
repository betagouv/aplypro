# frozen_string_literal: true

FactoryBot.define do
  factory :establishment do
    uai { Faker::Alphanumeric.alpha }
    name { Faker::Educator.secondary_school }
    denomination { "LYCEE GENERAL ET TECHNOLOGIQUE" }
    nature { Faker::Number.between(from: 300, to: 399) }
    postal_code { Faker::Address.postcode }
    city { Faker::Address.city }
    address_line1 { Faker::Address.street_address }
    address_line2 { Faker::Address.secondary_address }
    private_contract_type_code { "31" }
    academy_code { "10" }
    academy_label { "Marseille" }

    trait :with_fim_user do
      after(:create) do |establishment|
        create(:user, :director, provider: "fim", establishment: establishment)
      end
    end

    trait :with_masa_user do
      after(:create) do |establishment|
        create(:user, :director, provider: "masa", establishment: establishment)
      end
    end
  end
end
