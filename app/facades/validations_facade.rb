# frozen_string_literal: true

class ValidationsFacade
  attr_reader :establishment

  def initialize(establishment)
    @establishment = establishment
  end

  def failed_pfmps
    establishment.pfmps
                 .in_state(:validated)
                 .joins(:payment_requests)
                 .joins("INNER JOIN asp_payment_request_transitions ON \
asp_payment_requests.id = asp_payment_request_transitions.asp_payment_request_id")
                 .where(asp_payment_request_transitions: {
                          to_state: ASP::PaymentRequestStateMachine::FAILED_STATES,
                          most_recent: true
                        })
                 .includes(:student, payment_requests: :asp_payment_request_transitions)
  end

  def validatable_classes
    Classe.where(id: establishment.validatable_pfmps.distinct.pluck(:"classes.id"))
  end

  def classes_facade
    ClassesFacade.new(validatable_classes)
  end
end
