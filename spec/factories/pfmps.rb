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

    trait :validated do
      completed

      after(:create, &:validate!)
    end

    trait :with_pending_payment do
      validated
    end

    trait :paid do
      validated

      after(:create) do |pfmp|
        pfmp.latest_payment_request.tap do |p|
          p.mark_ready!

          p.asp_request = ASP::Request.create!

          p.mark_sent!
          p.mark_integrated!({})
          p.mark_paid!
        end
      end
    end

    trait :with_failed_payment do
      validated

      after(:create) do |pfmp|
        pfmp.latest_payment_request.tap do |p|
          p.mark_ready!

          p.asp_request = ASP::Request.create!

          p.mark_sent!
          p.mark_rejected!({})
        end
      end
    end
  end
end
