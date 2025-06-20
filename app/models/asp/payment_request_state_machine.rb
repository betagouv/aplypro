# frozen_string_literal: true

module ASP
  class PaymentRequestStateMachine
    include Statesman::Machine

    state :pending, initial: true
    state :incomplete
    state :ready
    state :sent
    state :rejected
    state :integrated
    state :paid
    state :unpaid

    ONGOING_STATES = %i[ready sent integrated].freeze
    FAILED_STATES = %i[rejected unpaid incomplete].freeze
    TERMINATED_STATES = FAILED_STATES + ["paid"].freeze

    transition from: :pending, to: :pending
    transition from: :pending, to: :ready
    transition from: :pending, to: :incomplete
    transition from: :incomplete, to: :incomplete
    transition from: :incomplete, to: :ready
    transition from: :incomplete, to: :pending
    transition from: :ready, to: :sent
    transition from: :sent, to: :rejected
    transition from: :sent, to: :integrated
    transition from: :integrated, to: :paid
    transition from: :integrated, to: :unpaid

    after_transition(from: :sent, to: :integrated) do |payment_request, transition|
      attrs = transition.metadata

      payment_request.student.update!(asp_individu_id: attrs["idIndDoss"])
      payment_request.schooling.update!(asp_dossier_id: attrs["idDoss"])
      payment_request.pfmp.update!(asp_prestation_dossier_id: attrs["idPretaDoss"])
    rescue ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid => e
      raise ASP::Errors::IntegrationError.new(
        "CSV Integration error for p_r #{payment_request.id} for data" \
        "#{transition.metadata} with message: #{e.message}",
        payment_request
      )
    end

    after_transition(from: :pending, to: :ready) do |payment_request, _|
      payment_request.update!(
        rib: payment_request.pfmp.student.rib(payment_request.pfmp.classe.establishment)
      )
    end

    guard_transition(to: :ready) do |payment_request|
      ASP::PaymentRequestValidator.new(payment_request).validate

      payment_request.payable? && payment_request.errors.none?
    end

    guard_transition(to: :incomplete) do |payment_request|
      payment_request.errors.any?
    end

    guard_transition(from: :ready, to: :sent) do |payment_request|
      payment_request.asp_request.present?
    end

    after_guard_failure(to: :ready) do |payment_request, _exception|
      raise ASP::Errors::FundingNotAvailableError unless payment_request.payable?

      raise(
        ASP::Errors::IncompletePaymentRequestError,
        "Conditions missing to mark the payment request as ready: #{payment_request.errors.full_messages.join('\n')}"
      )
    end
  end
end
