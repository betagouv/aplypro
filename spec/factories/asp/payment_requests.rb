# frozen_string_literal: true

FactoryBot.define do
  factory :asp_payment_request, class: "ASP::PaymentRequest" do
    payment

    trait :ready do
      after(:create) do |obj|
        obj.mark_ready!
      end
    end

    trait :sent do
      ready

      after(:create) do |obj|
        asp_request = create(:asp_request)

        obj.mark_as_sent!(asp_request)
      end
    end

    trait :integrated do
      sent

      after(:create) do |obj|
        obj.mark_integrated!({})
      end
    end

    trait :paid do
      integrated

      after(:create, &:mark_paid!)
    end
  end
end
