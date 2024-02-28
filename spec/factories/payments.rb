# frozen_string_literal: true

FactoryBot.define do
  factory :payment do
    pfmp
    amount { Faker::Number.positive }
  end
end
