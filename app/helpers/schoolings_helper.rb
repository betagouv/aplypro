# frozen_string_literal: true

module SchoolingsHelper
  def attributive_decision_badge(schooling)
    status = schooling.attributive_decision.attached? ? :success : :error
    success_badge(status, "Décision d'attribution")
  end
end
