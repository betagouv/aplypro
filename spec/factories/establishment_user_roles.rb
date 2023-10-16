# frozen_string_literal: true

FactoryBot.define do
  factory :establishment_user_role do
    establishment
    user

    trait :director do
      role { "dir" }
    end
  end
end
