# frozen_string_literal: true

FactoryBot.define do
  factory :establishment do
    uai { Faker::Alphanumeric.alpha }
    name { Faker::Educator.secondary_school }
    denomination { "LYCEE GENERAL ET TECHNOLOGIQUE" }
    nature { Faker::Number.between(from: 300, to: 399) }
    postal_code { Faker::Address.postcode }
    city { Faker::Address.city }

    trait :with_fim_user do
      after(:create) do |establishment|
        user = create(:user, provider: "fim")

        create(:establishment_user, establishment: establishment, user: user, role: :dir)
      end
    end

    trait :with_masa_user do
      after(:create) do |establishment|
        user = create(:user, provider: "masa")

        create(:establishment_user, establishment: establishment, user: user, role: :dir)
      end
    end
  end
end
