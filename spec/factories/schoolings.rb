# frozen_string_literal: true

FactoryBot.define do
  factory :schooling do
    student
    classe
    start_date { Date.yesterday - 1.month }
    status { :student }

    trait :with_attributive_decision do
      after(:create) do |schooling|
        AttributiveDecisionHelpers.generate_fake_attributive_decision(schooling)
      end
    end

    trait :with_abrogation_decision do
      after(:create) do |schooling|
        AttributiveDecisionHelpers.generate_fake_attributive_decision(schooling)
        AttributiveDecisionHelpers.generate_fake_abrogation_decision(schooling)
      end
    end

    trait :apprentice do
      status { :apprentice }
    end

    trait :closed do
      end_date { Date.yesterday }
    end
  end
end
