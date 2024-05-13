# frozen_string_literal: true

class ValidationsFacade
  attr_reader :establishment

  def initialize(establishment)
    @establishment = establishment
  end

  def failed_pfmps
    subquery = ASP::PaymentRequest.latest_per_pfmp.failed.to_sql

    Pfmp.joins(schooling: { classe: :establishment })
        .where(establishments: { id: establishment.id })
        .joins(:payment_requests)
        .joins("INNER JOIN (#{subquery}) as latest_payment_requests ON latest_payment_requests.pfmp_id = pfmps.id")
        .includes(:student, payment_requests: :asp_payment_request_transitions)
  end

  def validatable_classes
    Classe.where(id: establishment.validatable_pfmps.distinct.pluck(:"classes.id"))
  end

  def classes_facade
    ClassesFacade.new(validatable_classes)
  end
end
