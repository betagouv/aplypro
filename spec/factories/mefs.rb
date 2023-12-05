# frozen_string_literal: true

FactoryBot.define do
  factory :mef do
    code { Faker::Number.number(digits: 10) }
    label { "1CG" }
    short { "1ERE COLLAGE DE GOMETTES" }
    mefstat11 { 1234 }
    ministry { Mef.ministries[:menj] }

    after :create do |m|
      create(:wage, mef_code: m.code)
    end
  end
end
