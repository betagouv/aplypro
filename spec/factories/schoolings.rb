# frozen_string_literal: true

FactoryBot.define do
  factory :schooling do
    student
    classe
    start_date { "2023-08-26" }
    end_date { "2023-08-26" }

    trait :with_attributive_decision do
      after(:create) do |schooling|
        schooling.attributive_decision.attach(io: StringIO.new("hello"), filename: "test.pdf")
      end
    end
  end
end
