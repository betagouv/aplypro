# frozen_string_literal: true

FactoryBot.define do
  factory :mef do
    code { Faker::Number.number(digits: 10) }
    label { "1CG" }
    short { "1ERE COLLAGE DE GOMETTES" }
    mefstat11 { Faker::Number.number(digits: 11) }
    ministry { Mef.ministries[:menj] }
    school_year { SchoolYear.current }

    transient do
      daily_rate { 1 }
      yearly_cap { 100 }
    end

    after :create do |mef, evaluator|
      wage = create(:wage, daily_rate: evaluator.daily_rate, yearly_cap: evaluator.yearly_cap,
                           school_year: mef.school_year)
      wage.update!(mefstat4: mef.mefstat4, ministry: mef.ministry, mef_codes: [mef.code])
    end
  end
end
