# frozen_string_literal: true

FactoryBot.define do
  factory :asp_payment_request, class: "ASP::PaymentRequest" do
    payment

    trait :ready do
      after(:create) do |req|
        req.payment.pfmp.student = create(:student, :with_all_asp_info)

        req.mark_ready!
      end
    end

    trait :sent do
      ready

      after(:create) do |obj|
        create(:asp_request, asp_payment_requests: [obj])

        obj.mark_as_sent!
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
