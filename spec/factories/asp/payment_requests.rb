# frozen_string_literal: true

FactoryBot.define do
  factory :asp_payment_request, class: "ASP::PaymentRequest" do
    initialize_with { pfmp.payment_requests.last }

    transient do
      pfmp { association :pfmp, :validated, schooling: schooling }
      student { association :student, :with_all_asp_info, :underage }
      schooling { association :schooling, :with_attributive_decision, student: student }
    end

    trait :ready do
      after(:create, &:mark_ready!)
    end

    trait :incomplete do
      after(:create, &:mark_incomplete!)
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

      after(:create) do |obj|
        result = build(:asp_reject, payment_request: obj)

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

    trait :paid do
      integrated

      after(:create, &:mark_paid!)
    end
  end
end
