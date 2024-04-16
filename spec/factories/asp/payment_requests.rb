# frozen_string_literal: true

FactoryBot.define do
  factory :asp_payment_request, class: "ASP::PaymentRequest" do
    initialize_with { pfmp.payment_requests.last }

    pfmp { association :pfmp, :validated }

    trait :pending

    trait :sendable do
      after(:create) do |req|
        student = create(:student, :with_all_asp_info, :underage, :with_french_address)
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
        reason { Faker::Lorem.sentence(word_count: 20) }
      end

      after(:create) do |obj, ctx|
        result = build(:asp_reject, payment_request: obj, reason: ctx.reason)

        ASP::Readers::RejectsFileReader.new(io: result).process!
      end
    end

    trait :integrated do
      sent

      after(:create) do |obj|
        result = build(:asp_integration, payment_request: obj)

        ASP::Readers::IntegrationsFileReader.new(io: result).process!
      end
    end

    trait :paid do
      integrated

      after(:create) do |req|
        result = build(
          :asp_payment_file,
          :success,
          builder_class: ASP::Builder,
          payment_request: req
        )

        payment_return = create(:asp_payment_return)

        ASP::Readers::PaymentsFileReader.new(io: result, record: payment_return).process!

        req.reload
      end
    end

    trait :unpaid do
      integrated

      transient do
        reason { Faker::Lorem.sentence(word_count: 20) }
      end

      after(:create) do |payment_request, ctx|
        result = build(
          :asp_payment_file,
          :failed,
          builder_class: ASP::Builder,
          payment_request: payment_request,
          reason: ctx.reason
        )
        payment_return = create(:asp_payment_return)

        ASP::Readers::PaymentsFileReader.new(io: result, record: payment_return).process!

        payment_request.reload
      end
    end
  end
end
