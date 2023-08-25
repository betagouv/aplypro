# frozen_string_literal: true

FactoryBot.define do
  factory :pfmp do
    student
    start_date { "2023-05-22" }
    end_date { "2023-05-22" }
    day_count { rand(1..6) } # lovely roll dice

    trait :validated do
      after(:create) do |pfmp|
        pfmp.transition_to!(:validated)
      end
    end
  end
end
