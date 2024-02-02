# frozen_string_literal: true

FactoryBot.define do
  factory :mef do
    code { Faker::Number.number(digits: 10) }
    label { "1CG" }
    short { "1ERE COLLAGE DE GOMETTES" }
    mefstat11 { Faker::Number.number(digits: 11) }
    ministry { Mef.ministries[:menj] }

    transient do
      wage { create(:wage) } # rubocop:disable FactoryBot/FactoryAssociationWithStrategy
    end

    after :create do |mef, evaluator|
      evaluator.wage.update!(mefstat4: mef.mefstat4, ministry: mef.ministry, mef_codes: [mef.code])
    end
  end
end
