# frozen_string_literal: true

FactoryBot.define do
  factory :mefstat do
    code { Faker::Number.number(digits: 4) }
    label { "MyString" }
    short { "MyString" }
  end
end
