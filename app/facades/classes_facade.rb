# frozen_string_literal: true

class ClassesFacade
  attr_accessor :classes

  delegate :payment_requests_counts, to: :@payment_requests_facade

  def initialize(classes)
    @classes = classes
    # @payment_requests_facade = PaymentRequestsFacade.new()
  end

  def nb_students_per_class
    @nb_students_per_class ||= classes
                               .joins(:students)
                               .reorder(nil)
                               .group(:"classes.id")
                               .count
  end

  def nb_attributive_decisions_per_class
    @nb_attributive_decisions_per_class ||= classes
                                            .joins(:schoolings)
                                            .merge(Schooling.with_attributive_decisions)
                                            .group(:"classes.id")
                                            .count
  end

  def nb_ribs_per_class
    @nb_ribs_per_class ||= classes
                           .joins(students: :rib)
                           .reorder(nil)
                           .group(:"classes.id")
                           .count
  end

  def nb_pfmps(classe_id, status)
    nb_pfmp_per_class_and_status[[classe_id, status]]
  end

  def nb_pfmp_per_class_and_status
    @nb_pfmp_per_class_and_status ||= transform_pfmp_status_keys(
      classes
      .joins(:pfmps)
      .reorder(nil)
      .joins(Pfmp.most_recent_transition_join)
      .group(:"classes.id", :to_state)
      .count
    )
  end

  def transform_pfmp_status_keys(hash)
    hash.transform_keys do |classe_id, state|
      [classe_id, state.blank? ? :pending : state.to_sym]
    end
  end
end
