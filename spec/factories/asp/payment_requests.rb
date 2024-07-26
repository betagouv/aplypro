# frozen_string_literal: true

FactoryBot.define do
  factory :asp_payment_request, class: "ASP::PaymentRequest" do
    # rubocop:disable Layout/LineLength
    missing_abrogation_error = I18n.t("activerecord.errors.models.asp/payment_request.attributes.ready_state_validation.needs_abrogated_attributive_decision")
    missing_da_error = I18n.t("activerecord.errors.models.asp/payment_request.attributes.ready_state_validation.missing_attributive_decision")
    # rubocop:enable Layout/LineLength

    pfmp do
      association(:pfmp, :validated).tap { |p| p.payment_requests.destroy_all }
    end

    trait :pending

    trait :sendable do
      after(:create) do |req|
        student = build(:student, :with_all_asp_info, :adult, :with_french_address)
        req.student.update!(**student.attributes.except("id", "updated_at", "created_at"))
        create(:rib, :personal, student: req.student) if req.student.rib.blank?
        AttributiveDecisionHelpers.generate_fake_attributive_decision(req.schooling)
        req.reload ## needed to reload the data of the schooling for the asp xml builder
      end
    end

    trait :sendable_with_issues do
      after(:create) do |req|
        student = build(:student, :with_all_asp_info, :underage, :with_foreign_address, biological_sex: nil)
        req.student.update!(**student.attributes.except("id", "updated_at", "created_at"))
        AttributiveDecisionHelpers.generate_fake_attributive_decision(req.schooling)
        req.reload ## needed to reload the data of the schooling for the asp xml builder
      end
    end

    trait :ready do
      sendable

      after(:create, &:mark_ready!)
    end

    trait :incomplete do
      after(:create) do |req|
        req.pfmp.student.update!(birthplace_country_insee_code: nil)

        req.mark_ready!
      end
    end

    trait :incomplete_for_missing_abrogation_da do
      sendable

      after(:create) do |req|
        req.errors.add(:ready_state_validation, :needs_abrogated_attributive_decision)
        req.mark_incomplete!(incomplete_reasons: { ready_state_validation: [missing_abrogation_error] })
      end
    end

    trait :incomplete_for_missing_da do
      sendable

      after(:create) do |req|
        req.errors.add(:ready_state_validation, :needs_abrogated_attributive_decision)
        req.mark_incomplete!(incomplete_reasons: { ready_state_validation: [missing_da_error] })
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
