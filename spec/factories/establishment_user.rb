# frozen_string_literal: true

FactoryBot.define do
  factory :establishment_user do
    establishment
    user
    role { "dir" }
  end
end
