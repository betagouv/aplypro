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
      transient do
        day_count { 3 }
      end
      after(:create) do |pfmp, eval|
        PfmpManager.new(pfmp).update!(day_count: eval.day_count)
      end
    end

    trait :can_be_validated do
      completed

      after(:create) do |pfmp|
        if pfmp.student.rib(pfmp.establishment).blank?
          create(:rib, :personal, student: pfmp.student,
                                  establishment: pfmp.establishment)
        end
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

    after(:build) do |pfmp, _|
      PfmpManager.new(pfmp).update!(day_count: pfmp.day_count) if pfmp.day_count.present?
    end
  end
end
