# frozen_string_literal: true

FactoryBot.define do
  factory :payment do
    pfmp
    amount { Faker::Number.positive }

    trait :ready do
      after(:create, &:mark_ready!)
    end

    trait :processing do
      ready

      after(:create, &:process!)
    end

    trait :successful do
      processing

      after(:create, &:complete!)
    end

    trait :failed do
      processing

      after(:create, &:fail!)
    end
  end
end
