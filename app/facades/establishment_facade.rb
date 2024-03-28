# frozen_string_literal: true

class EstablishmentFacade
  attr_accessor :establishment

  delegate :payment_requests_counts, to: :@payment_requests_facade

  def initialize(establishment)
    @establishment = establishment
    @payment_requests_facade = PaymentRequestsFacade.new(current_payment_requests)
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

  private

  def pfmps
    establishment.pfmps.merge(Classe.current)
  end

  def current_payment_requests
    establishment.payment_requests.merge(Classe.current)
  end

  def current_classes
    establishment.classes.current
  end
end
