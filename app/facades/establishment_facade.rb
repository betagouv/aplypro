# frozen_string_literal: true

class EstablishmentFacade
  attr_accessor :establishment

  def initialize(establishment)
    @establishment = establishment
  end

  def schoolings_count
    @schoolings_count ||= current_classes.joins(:schoolings).count
  end

  def attributive_decisions_count
    @attributive_decisions_count ||= current_classes
                                     .joins(:schoolings)
                                     .merge(Schooling.with_attributive_decisions)
                                     .count
  end

  def students_count
    @students_count ||= current_classes
                        .joins(:students)
                        .distinct(:"students.id")
                        .count(:"students.id")
  end

  def ribs_count
    @ribs_count ||= current_classes.joins(students: :rib).distinct(:"students.id").count(:"ribs.id")
  end

  def pfmps_counts
    @pfmps_counts ||= PfmpStateMachine
                      .states
                      .map(&:to_sym)
                      .index_with { |state| pfmps.in_state(state).count }
  end

  def payment_requests_counts
    @payment_requests_counts ||= begin
      grouped_states = ASP::PaymentRequest::PAYMENT_STAGES
                       .map { |stages| [stages[0..-2], [stages.last]] }
                       .reduce(&:concat)

      grouped_states.to_h do |states|
        count = states.map { |state| payment_requests_all_status_counts[state] }.compact.sum
        [states.first, count]
      end
    end
  end

  def pfmps
    establishment.pfmps.merge(Classe.current)
  end

  def current_classes
    establishment.classes.current
  end

  def initial_state
    ASP::PaymentRequestStateMachine.initial_state.to_sym
  end

  def payment_requests_all_status_counts
    @payment_requests_all_status_counts ||=
      current_payment_requests
      .joins(ASP::PaymentRequest.most_recent_transition_join)
      .group(:to_state)
      .count
      .transform_keys { |state| state.nil? ? initial_state : state.to_sym }
  end

  def current_payment_requests
    establishment.payment_requests.merge(Classe.current)
  end
end
