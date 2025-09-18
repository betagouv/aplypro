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
                               schooling.classe.establishment.school_year_range(
                                 schooling.classe.school_year.start_year
                               ).first
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
      end_date { Date.parse("#{classe.school_year.start_year}-09-18") }
    end

    trait :extended do
      extended_end_date { Date.parse("#{classe.school_year.end_year}-09-30") }
    end
  end
end
