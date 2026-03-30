# frozen_string_literal: true

module SchoolingsHelper
  def attributive_decision_badge(schooling)
    success_badge(schooling.attributive_decision.attached?, "Décision d'attribution")
  end

  def attributive_decision_status_badge(schooling)
    if schooling.attributive_decision.attached?
      if schooling.abrogation_decision.attached?
        dsfr_badge(status: :error) { "Abrogée" }
      elsif schooling.cancellation_decision.attached?
        dsfr_badge(status: :error) { "Annulée" }
      else
        dsfr_badge(status: :success) { "Générée" }
      end
    elsif schooling.generating_attributive_decision
      dsfr_badge(status: :info) { "En cours de génération" }
    else
      dsfr_badge(status: :error) { "Non générée" }
    end
  end

  def display_dates(schooling)
    start_date = schooling.start_date
    end_date = schooling.end_date
    if start_date.present? || end_date.present?
      string = start_date.present? ? "débutée le #{format_date(start_date)}" : ""
      string += " et " if start_date.present? && end_date.present?
      string += end_date.present? ? "finie le #{format_date(end_date)}" : ""
      return "Scolarité #{string}"
    end
    ""
  end

  def warning_schooling_dates(schooling)
    year = schooling.school_year.start_year
    school_year_range = schooling.establishment.school_year_range(year)

    start_date = schooling.start_date.present? ? schooling.start_date : school_year_range.first
    end_date = schooling.max_end_date.present? ? schooling.max_end_date : school_year_range.last

    "Les dates saisies doivent être comprises dans la durée de la scolarité de l'élève
      (entre le #{format_date(start_date)} et le #{format_date(end_date)})."
  end
end
