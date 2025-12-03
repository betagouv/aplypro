# frozen_string_literal: true

class ValidationsFacade
  attr_reader :establishment, :school_year

  def initialize(establishment, school_year)
    @establishment = establishment
    @school_year = school_year
  end

  def failed_pfmps_per_payment_request_state
    pfmp_ids = establishment.pfmps
                            .for_year(school_year.start_year)
                            .pluck(:id)

    failed_payment_requests = ASP::PaymentRequest
                              .where(pfmp_id: pfmp_ids)
                              .latest_per_pfmp
                              .failed
                              .includes(pfmp: [:student])

    failed_payment_requests
      .group_by(&:current_state)
      .transform_values { |payment_requests| payment_requests.map(&:pfmp) }
  end

  def validatable_classes
    Classe.where(id: establishment.validatable_pfmps.distinct.pluck(:"classes.id"), school_year: school_year)
  end

  def classes_facade
    ClassesFacade.new(validatable_classes, @establishment)
  end
end
