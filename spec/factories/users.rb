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

    transient do
      role { "dir" }
    end

    after(:create) do |user, evaluator|
      EstablishmentUser
        .find_or_initialize_by(establishment: user.establishment, user: user)
        .update!(role: evaluator.role)
    end
  end
end
