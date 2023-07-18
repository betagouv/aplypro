# frozen_string_literal: true

FactoryBot.define do
  factory :mef do
    code { Faker::Number.number(digits: 10) }
    label { "MyString" }
    short { "MyString" }
    mefstat11 { 1234 }
    ministry { Mef.ministries[:menj] }
  end
end
