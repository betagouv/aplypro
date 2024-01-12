# frozen_string_literal: true

module SchoolingsHelper
  def attributive_decision_badge(schooling)
    success_badge(schooling.attributive_decision.attached?, "Décision d'attribution")
  end
end
