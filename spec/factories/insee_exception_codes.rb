# frozen_string_literal: true

FactoryBot.define do
  factory :insee_exception_codes do
    code_type { "address" }
    entry_code { "1234A" }
    exit_code { "54321" }

    trait :expired do
      expired_at { Date.yesterday }
    end
  end
end
