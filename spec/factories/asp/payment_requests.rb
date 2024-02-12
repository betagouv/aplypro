# frozen_string_literal: true

FactoryBot.define do
  factory :asp_payment_request, class: "ASP::PaymentRequest" do
    asp_request
    payment

    trait :sent do
      after(:create, &:mark_as_sent!)
    end
  end
end
