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
      ASP::StudentFileEligibilityChecker.new(request.student).ready?
    end

    guard_transition(to: :ready) do |request|
      !request.student.adult_without_personal_rib?
    end

    guard_transition(to: :ready) do |request|
      request.pfmp.amount.positive?
    end

    guard_transition(to: :ready) do |request|
      request.pfmp.schooling.attributive_decision.attached?
    end

    guard_transition(from: :ready, to: :sent) do |request|
      request.asp_request.present?
    end
  end
end
