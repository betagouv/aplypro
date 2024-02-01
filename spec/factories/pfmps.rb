# frozen_string_literal: true

FactoryBot.define do
  factory :pfmp do
    schooling { association :schooling, student: student }
    start_date { "2023-05-22" }
    end_date { "2023-05-22" }

    transient do
      student { build(:student) } # rubocop:disable FactoryBot/FactoryAssociationWithStrategy
    end

    trait :completed do
      day_count { rand(1..6) } # lovely roll dice
    end

    trait :validated do
      completed

      after(:create) do |pfmp|
        pfmp.transition_to!(:validated)
      end
    end

    trait :with_pending_payment do
      validated
    end

    trait :paid do
      validated

      after(:create) do |pfmp|
        pfmp.payments.first.tap do |p|
          p.mark_ready!
          p.process!
          p.complete!
        end
      end
    end

    trait :with_failed_payment do
      validated

      after(:create) do |pfmp|
        pfmp.payments.first.tap do |p|
          p.mark_ready!
          p.process!
          p.fail!
        end
      end
    end
  end
end
