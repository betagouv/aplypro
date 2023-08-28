# frozen_string_literal: true

FactoryBot.define do
  factory :pfmp do
    schooling
    start_date { "2023-05-22" }
    end_date { "2023-05-22" }

    trait :completed do
      day_count { rand(1..6) } # lovely roll dice
    end

    trait :validated do
      completed

      after(:create) do |pfmp|
        pfmp.transition_to!(:validated)
      end
    end
  end
end
