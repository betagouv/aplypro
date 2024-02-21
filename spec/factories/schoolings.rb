# frozen_string_literal: true

FactoryBot.define do
  factory :schooling do
    student
    classe
    start_date { "2023-08-26" }

    trait :with_attributive_decision do
      after(:create) do |schooling|
        schooling.generate_administrative_number.tap(&:save!)

        schooling.rattach_attributive_decision!(StringIO.new("hello"))
      end
    end

    trait :closed do
      end_date { Date.yesterday }
    end
  end
end
