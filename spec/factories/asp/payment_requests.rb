# frozen_string_literal: true

FactoryBot.define do
  factory :asp_payment_request, class: "ASP::PaymentRequest" do
    transient do
      student_traits { [] }
    end

    pfmp do
      association(:pfmp, :validated, student_traits: student_traits).tap do |p|
        p.payment_requests.destroy_all
      end
    end

    trait :pending

    trait :sendable do
      after(:create) do |req, evaluator|
        student = build(:student, :with_all_asp_info, :adult, :with_french_address, *evaluator.student_traits)
        req.student.update!(**student.attributes.except("id", "updated_at", "created_at"))
        req.reload ## needed to reload the data of the schooling for the asp xml builder
      end
    end

    trait :sendable_with_issues do
      after(:create) do |req|
        student = build(:student, :with_all_asp_info, :underage, :with_foreign_address, biological_sex: nil)
        req.student.update!(**student.attributes.except("id", "updated_at", "created_at"), ribs: [])
        req.reload # needed to reload the data of the schooling for the asp xml builder
      end
    end

    trait :ready do
      sendable

      after(:create, &:mark_ready!)
    end

    trait :incomplete do
      sendable

      transient { incomplete_reason { :ine_not_found } }

      after(:create) do |req, ctx|
        req.errors.add(:ready_state_validation, ctx.incomplete_reason)
        req.mark_incomplete!(
          incomplete_reasons: {
            ready_state_validation:
              [
                I18n.t(
                  "asp/payment_request.attributes.ready_state_validation.#{ctx.incomplete_reason}",
                  scope: "activerecord.errors.models"
                )
              ]
          }
        )
      end
    end

    trait :sent do
      ready

      after(:create) do |obj|
        create(:asp_request, asp_payment_requests: [obj])

        obj.mark_sent!
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
