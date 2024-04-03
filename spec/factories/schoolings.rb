# frozen_string_literal: true

FactoryBot.define do
  factory :schooling do
    student
    classe
    start_date { "2023-08-26" }
    status { :student }

    trait :with_attributive_decision do
      after(:create) do |schooling|
        schooling.tap(&:generate_administrative_number).save!

        schooling.rattach_attributive_decision!(StringIO.new("hello"))
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
