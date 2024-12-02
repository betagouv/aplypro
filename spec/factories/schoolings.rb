# frozen_string_literal: true

FactoryBot.define do
  factory :schooling do
    student
    classe
    status { :student }

    after(:build) do |schooling|
      schooling.start_date = if schooling.end_date.present?
                               schooling.end_date - 1.month
                             else
                               Date.parse("#{SchoolYear.current.start_year}-09-10")
                             end
    end

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
      end_date { Date.parse("#{SchoolYear.current.start_year}-12-01") }
    end

    trait :extended do
      extended_end_date { Date.parse("#{SchoolYear.current.start_year + 1}-09-30") }
    end
  end
end
