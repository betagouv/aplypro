# frozen_string_literal: true

module ASP
  class PaymentRequestStateMachine
    include Statesman::Machine

    state :pending, initial: true
    state :sent
    state :rejected
    state :integrated

    transition from: :pending, to: :sent
    transition from: :sent, to: :rejected
    transition from: :sent, to: :integrated

    after_transition(from: :sent, to: :integrated) do |request, transition|
      attrs = transition.metadata

      request.payment.student.update!(asp_individu_id: attrs["idIndDoss"])
      request.payment.schooling.update!(asp_dossier_id: attrs["idDoss"])
      request.payment.pfmp.update!(asp_prestation_dossier_id: attrs["idPretaDoss"])
    end
  end
end
