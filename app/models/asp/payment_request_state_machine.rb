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

    transition from: :pending, to: :ready
    transition from: :pending, to: :incomplete
    transition from: :ready, to: :sent
    transition from: :sent, to: :rejected
    transition from: :sent, to: :integrated
    transition from: :integrated, to: :paid
    transition from: :integrated, to: :unpaid

    after_transition(from: :sent, to: :integrated) do |request, transition|
      attrs = transition.metadata

      request.payment.student.update!(asp_individu_id: attrs["idIndDoss"])
      request.payment.schooling.update!(asp_dossier_id: attrs["idDoss"])
      request.payment.pfmp.update!(asp_prestation_dossier_id: attrs["idPretaDoss"])
    end

    guard_transition(from: :pending, to: :ready) do |request|
      ASP::StudentFileEligibilityChecker.new(request.payment.student).ready?
    end
  end
end
