# frozen_string_literal: true

FactoryBot.define do
  factory :pfmp do
    student
    start_date { "2023-05-22" }
    end_date { "2023-05-22" }
    day_count { rand(1..6) } # lovely roll dice
  end
end
