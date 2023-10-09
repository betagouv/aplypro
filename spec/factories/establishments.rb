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
      association :user, provider: "fim" # rubocop:disable FactoryBot/AssociationStyle
    end

    trait :with_masa_user do
      association :user, provider: "masa" # rubocop:disable FactoryBot/AssociationStyle
    end
  end
end
