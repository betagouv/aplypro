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
    FAILED_STATES = %i[rejected unpaid].freeze
    TERMINATED_STATES = FAILED_STATES + ["paid"].freeze

    transition from: :pending, to: :ready
    transition from: :pending, to: :incomplete
    transition from: :incomplete, to: :ready
    transition from: :ready, to: :sent
    transition from: :sent, to: :rejected
    transition from: :sent, to: :integrated
    transition from: :integrated, to: :paid
    transition from: :integrated, to: :unpaid

    after_transition(from: :sent, to: :integrated) do |request, transition|
      attrs = transition.metadata

      request.student.update!(asp_individu_id: attrs["idIndDoss"])
      request.schooling.update!(asp_dossier_id: attrs["idDoss"])
      request.pfmp.update!(asp_prestation_dossier_id: attrs["idPretaDoss"])
    end

    guard_transition(to: :ready) do |request|
      request.completion_status.values.all?(true)
    end

    guard_transition(from: :ready, to: :sent) do |request|
      request.asp_request.present?
    end

    after_guard_failure(from: :pending, to: :ready) do |request, _exception|
      raise(
        Statesman::GuardFailedError.new(
          :pending,
          :ready,
          lambda {
            "Some checks are missing to transition from pending to ready: #{request.completion_status.select do |_k, v|
                                                                              v == false
                                                                            end}"
          }
        )
      )
    end
  end
end
