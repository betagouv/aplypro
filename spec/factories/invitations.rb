# frozen_string_literal: true

require "faker"

FactoryBot.define do
  factory :invitation do
    user
    establishment
    sequence :email do |n|
      "user_#{n}@education.gouv.fr"
    end
  end
end
