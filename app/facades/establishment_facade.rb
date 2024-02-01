# frozen_string_literal: true

class EstablishmentFacade
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

  def pfmps
    Pfmp.joins(:classe).where(schooling: { classe: current_classes })
  end

  def current_classes
    @establishment.classes.current
  end
end
