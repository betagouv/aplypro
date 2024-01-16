# frozen_string_literal: true

module ClassesHelper
  def attributive_decision_progress_badge(classe)
    count = classe.active_schoolings.with_attributive_decisions.count
    total = classe.active_students.size

    progress_badge(count, total)
  end

  def ribs_progress_badge(classe)
    count = classe.active_students.joins(:rib).count
    total = classe.active_students.size

    progress_badge(count, total)
  end

  def pfmp_progress_badge(classe, state)
    count = classe.pfmps.merge(Schooling.current).in_state(state).count

    pfmp_badge(state, count)
  end
end
