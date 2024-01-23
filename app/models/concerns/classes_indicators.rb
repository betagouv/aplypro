# frozen_string_literal: true

module ClassesIndicators
  def nb_students_per_class(classes)
    classes.joins(:active_students)
           .reorder(nil)
           .group(:"classes.id")
           .count
  end

  def nb_attributive_decisions_per_class(classes)
    classes.joins(:active_schoolings)
           .merge(Schooling.with_attributive_decisions)
           .group(:"classes.id")
           .count
  end

  def nb_ribs_per_class(classes)
    classes.joins(active_students: :rib)
           .reorder(nil)
           .group(:"classes.id")
           .count
  end

  def nb_pfmp_per_class_and_status(classes)
    classes.joins(:active_pfmps)
           .reorder(nil)
           .joins(Pfmp.most_recent_transition_join)
           .group(:"classes.id", :to_state)
           .count
           .transform_keys { |classe_id, state| [classe_id, state.blank? ? :pending : state.to_sym] }
  end
end
