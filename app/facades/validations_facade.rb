# frozen_string_literal: true

class ValidationsFacade
  attr_reader :establishment, :school_year

  def initialize(establishment, school_year)
    @establishment = establishment
    @school_year = school_year
  end

  # TODO: this query somehow (cant reproduce) returns p_r also not in failed state
  # the reject at the end is duct tape to prevent that from happening
  def failed_pfmps_per_payment_request_state # rubocop:disable Metrics/AbcSize
    pfmps = Pfmp.joins(schooling: { classe: :establishment })
                .where(establishments: { id: establishment.id })
                .joins(:payment_requests)
                .joins("INNER JOIN (#{establishment.latest_per_pfmp.failed.to_sql}) as latest_payment_requests
                        ON latest_payment_requests.pfmp_id = pfmps.id")
                .includes(:student, payment_requests: :asp_payment_request_transitions)

    pfmps.group_by { |pfmp| pfmp.latest_payment_request.current_state }
         .reject { |pfmp_state| ASP::PaymentRequestStateMachine::FAILED_STATES.exclude?(pfmp_state.to_sym) }
  end

  def validatable_classes
    Classe.where(id: establishment.validatable_pfmps.distinct.pluck(:"classes.id"), school_year: school_year)
  end

  def classes_facade
    ClassesFacade.new(validatable_classes)
  end
end
