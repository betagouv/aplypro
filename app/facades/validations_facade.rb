# frozen_string_literal: true

class ValidationsFacade
  attr_reader :establishment

  def initialize(establishment)
    @establishment = establishment
  end

  def failed_pfmps
    Pfmp.joins(schooling: { classe: :establishment })
        .where(establishments: { id: establishment.id })
        .joins(:payment_requests)
        .merge(ASP::PaymentRequest.failed.latest_per_pfmp)
        .includes(:student, payment_requests: :asp_payment_request_transitions)
  end

  def validatable_classes
    Classe.where(id: establishment.validatable_pfmps.distinct.pluck(:"classes.id"))
  end

  def classes_facade
    ClassesFacade.new(validatable_classes)
  end
end
