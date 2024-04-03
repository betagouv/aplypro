# frozen_string_literal: true

FactoryBot.define do
  factory :asp_payment_request, class: "ASP::PaymentRequest" do
    initialize_with { pfmp.payment_requests.last }

    pfmp { association :pfmp, :validated }

    trait :pending

    trait :sendable do
      after(:create) do |req|
        student = create(:student, :with_all_asp_info, :underage)
        schooling = create(:schooling, :with_attributive_decision, student: student)

        req.pfmp.update!(schooling: schooling)
      end
    end

    trait :ready do
      sendable

      after(:create, &:mark_ready!)
    end

    trait :incomplete do
      after(:create) do |req|
        student = create(:student, :with_all_asp_info, :underage)
        schooling = create(:schooling, :with_attributive_decision, student: student)
        req.pfmp.update!(schooling: schooling)

        req.mark_incomplete!
      end
    end

    trait :sent do
      ready

      after(:create) do |obj|
        create(:asp_request, asp_payment_requests: [obj])

        obj.mark_as_sent!
      end
    end

    trait :rejected do
      sent

      transient do
        reason { "fail" }
      end

      after(:create) do |obj, ctx|
        result = build(:asp_reject, payment_request: obj, reason: ctx.reason)

        ASP::Readers::RejectsFileReader.new(result).process!
      end
    end

    trait :integrated do
      sent

      after(:create) do |obj|
        result = build(:asp_integration, payment_request: obj)

        ASP::Readers::IntegrationsFileReader.new(result).process!
      end
    end

    trait :rejected do
      sent

      after(:create) do |obj|
        obj.reject!({})
      end
    end

    trait :paid do
      integrated

      after(:create, &:mark_paid!)
    end

    trait :unpaid do
      integrated

      after(:create, &:mark_unpaid!)
    end
  end
end
