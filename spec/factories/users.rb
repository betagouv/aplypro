# frozen_string_literal: true

require "faker"

FactoryBot.define do
  factory :user do
    establishment
    uid { Faker::Alphanumeric.alpha }
    name { Faker::Name.name }
    provider { "MyString" }
    secret { "MyString" }
    token { "MyString" }
    email { Faker::Internet.email }
    welcomed { true }

    trait :newbie do
      welcomed { false }
    end

    trait :director do
      after(:create) do |user, _|
        EstablishmentUserRole
          .find_or_initialize_by(establishment: user.establishment, user: user)
          .update!(role: :dir)
      end
    end

    trait :authorised do
      after(:create) do |user, _|
        EstablishmentUserRole
          .find_or_initialize_by(establishment: user.establishment, user: user)
          .update!(role: :authorised)
      end
    end

    trait :confirmed_director do
      director

      after(:create) do |user|
        user.establishment.update!(confirmed_director: user)
      end
    end
  end
end
