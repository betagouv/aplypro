# frozen_string_literal: true

FactoryBot.define do
  factory :pfmp do
    student { association :student, :with_rib }
    schooling { association :schooling, :with_attributive_decision, student: student }

    start_date { "#{SchoolYear.current.start_year}-09-03" }
    end_date { "#{SchoolYear.current.start_year}-09-28" }

    trait :completed do
      day_count { rand(1..6) } # lovely roll dice
    end

    trait :validated do
      completed

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
