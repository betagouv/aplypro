# frozen_string_literal: true

FactoryBot.define do
  factory :pfmp do
    schooling { association :schooling, student: student }
    start_date { "#{SchoolYear.current.start_year}-09-03" }
    end_date { "#{SchoolYear.current.start_year}-09-28" }

    transient do
      student { build(:student) } # rubocop:disable FactoryBot/FactoryAssociationWithStrategy
    end

    trait :completed do
      day_count { rand(1..6) } # lovely roll dice
    end

    trait :can_be_validated do
      completed

      transient do
        student_traits { [] }
      end

      after(:create) do |pfmp, evaluator|
        student = create(:student, :with_all_asp_info, *evaluator.student_traits)
        pfmp.schooling.update!(student: student)
        AttributiveDecisionHelpers.generate_fake_attributive_decision(pfmp.schooling)
        pfmp.reload
      end
    end

    trait :validated do
      can_be_validated
      after(:create, &:validate!)
    end

    trait :with_pending_payment do
      validated
    end

    trait :rectified do
      validated

      after(:create) do |pfmp|
        create(:asp_payment_request, :paid, pfmp: pfmp)
        pfmp.reload.rectify!
      end
    end
  end
end
