# frozen_string_literal: true

require "faker"

FactoryBot.define do
  factory :user do
    establishment
    uid { Faker::Alphanumeric.alpha }
    name { Faker::Name.name }
    provider { "MyString" }
    secret { "MyString" }
    token { "MyString" }
    email { Faker::Internet.email }
    welcomed { true }

    trait :newbie do
      welcomed { false }
    end
  end
end
