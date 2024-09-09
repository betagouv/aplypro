# frozen_string_literal: true

class ClasseFacade
  def initialize(classe)
    @classe = classe
  end

  def nb_pending_pfmps
    @nb_pending_pfmps ||= @classe.pfmps.in_state(:pending).count
  end

  def nb_completed_pfmps
    @nb_completed_pfmps ||= @classe.pfmps.in_state(:completed).count
  end

  def nb_missing_ribs
    @nb_missing_ribs ||= @classe.students.without_ribs.count
  end

  def schoolings
    @classe.schoolings
           .includes(:attributive_decision_attachment, pfmps: :transitions, student: :rib)
           .order("students.last_name", "students.first_name")
  end

  def missing_ribs_button_text
    "Saisir #{nb_missing_ribs} #{'coordonnée'.pluralize(nb_missing_ribs)} #{'bancaire'.pluralize(nb_missing_ribs)}"
  end

  def pending_pfmps_button_text
    "Compléter #{nb_pending_pfmps} #{'PFMP'.pluralize(nb_pending_pfmps)}"
  end

  def completed_pfmps_button_text
    "Valider #{nb_completed_pfmps} #{'PFMP'.pluralize(nb_completed_pfmps)}"
  end
end
