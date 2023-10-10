# frozen_string_literal: true

FactoryBot.define do
  factory :schooling do
    student
    classe
    start_date { "2023-08-26" }
    end_date { "2023-08-26" }

    trait :with_attributive_decision do
      after(:create, &:generate_attributive_decision)
    end
  end
end
