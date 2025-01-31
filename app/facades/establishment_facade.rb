# frozen_string_literal: true

class EstablishmentFacade
  attr_accessor :establishment, :school_year

  STATES_GROUPS_FOR_COUNTS = [
    %i[pending ready], [:incomplete], %i[sent integrated], [:rejected], [:paid], [:unpaid]
  ].freeze

  def initialize(establishment, school_year)
    @establishment = establishment
    @school_year = school_year
  end

  def selected_schoolings
    @selected_schoolings ||= establishment.schoolings.for_year(school_year.start_year)
  end

  def attributive_decisions_count
    @attributive_decisions_count ||= selected_classes
                                     .joins(:schoolings)
                                     .merge(Schooling.with_attributive_decisions)
                                     .count
  end

  def without_attributive_decisions_count
    @without_attributive_decisions_count ||= selected_classes
                                             .joins(:schoolings)
                                             .merge(Schooling.without_attributive_decisions)
                                             .count
  end

  def students_count
    @students_count ||= selected_classes
                        .joins(:students)
                        .distinct(:"students.id")
                        .count(:"students.id")
  end

  def ribs_count
    @ribs_count ||= selected_classes
                    .joins(students: :ribs)
                    .where(ribs: { archived_at: nil })
                    .distinct(:"students.id")
                    .count(:"students.id")
  end

  def students_without_rib_count
    @students_without_rib_count ||= students_count - ribs_count
  end

  def pfmps_counts
    @pfmps_counts ||= PfmpStateMachine
                      .states
                      .map(&:to_sym)
                      .index_with { |state| pfmps.in_state(state).count }
  end

  def payment_requests_counts
    @payment_requests_counts ||= STATES_GROUPS_FOR_COUNTS.to_h do |states|
      count = states.map { |state| payment_requests_all_status_counts[state] }.compact.sum
      [states.first, count]
    end
  end

  private

  def payment_requests_all_status_counts
    @payment_requests_all_status_counts ||=
      selected_payment_requests
      .joins(ASP::PaymentRequest.most_recent_transition_join)
      .group(:to_state)
      .count
      .transform_keys { |state| state.nil? ? initial_state : state.to_sym }
  end

  def pfmps
    establishment.pfmps.merge(Classe.for_year(school_year.start_year))
  end

  def selected_payment_requests
    establishment.payment_requests.latest_per_pfmp.merge(Classe.for_year(school_year.start_year))
  end

  def selected_classes
    establishment.classes.for_year(school_year.start_year)
  end

  def initial_state
    ASP::PaymentRequestStateMachine.initial_state.to_sym
  end
end
