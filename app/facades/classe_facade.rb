# frozen_string_literal: true

class ClasseFacade
  def initialize(classe)
    @classe = classe
  end

  def nb_pending_pfmps
    @nb_pending_pfmps ||= @classe.pfmps.in_state(:pending).count
  end

  def nb_can_transition_to_validated_pfmps
    @nb_can_transition_to_validated_pfmps ||= @classe.pfmps
                                                     .in_state(:completed)
                                                     .filter { |pfmp| pfmp.can_transition_to?(:validated) }
                                                     .count
  end

  def nb_missing_ribs
    @nb_missing_ribs ||= @classe.active_students.without_ribs.count
  end

  def nb_active_schoolings
    @nb_active_schoolings ||= @classe.active_students.count
  end

  def schoolings
    @classe.schoolings
           .includes(:attributive_decision_attachment, pfmps: :transitions, student: :ribs)
           .order("students.last_name", "students.first_name")
  end

  def missing_ribs_button_text
    "Saisir #{nb_missing_ribs} #{'coordonnée'.pluralize(nb_missing_ribs)} #{'bancaire'.pluralize(nb_missing_ribs)}"
  end

  def pending_pfmps_button_text
    "Compléter #{nb_pending_pfmps} #{'PFMP'.pluralize(nb_pending_pfmps)}"
  end

  def can_transition_to_validated_pfmps_button_text
    "Valider #{nb_can_transition_to_validated_pfmps} #{'PFMP'.pluralize(nb_can_transition_to_validated_pfmps)}"
  end
end
