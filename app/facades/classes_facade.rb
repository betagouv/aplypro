# frozen_string_literal: true

class ClassesFacade
  def initialize(classes, establishment)
    @classes = classes.includes(
      :school_year,
      students: :ribs,
      schoolings:
        [
          { attributive_decision_attachment: :blob },
          { abrogation_decision_attachment: :blob }
        ]
    )
    @establishment = establishment
  end

  def nb_pfmps(class_id, state)
    pfmps_by_classe_and_state.dig(class_id, state.to_s) || 0
  end

  def nb_payment_requests(classe, states)
    classe.pfmps.count do |pfmp|
      p_r = pfmp.latest_payment_request
      p_r.present? && p_r.in_state?(states)
    end
  end

  private

  def pfmps_by_classe_and_state
    @pfmps_by_classe_and_state ||= group_pfmps_by_classe_and_state
  end

  def group_pfmps_by_classe_and_state
    counts = {}

    Pfmp.joins(:schooling)
        .joins("LEFT JOIN pfmp_transitions ON pfmp_transitions.pfmp_id = pfmps.id AND pfmp_transitions.most_recent = true") # rubocop:disable Layout/LineLength
        .where(schoolings: { classe_id: @classes.pluck(:id), removed_at: nil })
        .group("schoolings.classe_id", "COALESCE(pfmp_transitions.to_state, 'pending')")
        .count
        .each do |(class_id, state), count|
      counts[class_id] ||= {}
      counts[class_id][state.presence || "pending"] = count
    end

    counts
  end
end
