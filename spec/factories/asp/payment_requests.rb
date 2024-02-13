# frozen_string_literal: true

FactoryBot.define do
  factory :asp_payment_request, class: "ASP::PaymentRequest" do
    payment

    trait :sent do
      after(:create) do |obj|
        asp_request = create(:asp_request)

        obj.mark_as_sent!(asp_request)
      end
    end
  end
end
