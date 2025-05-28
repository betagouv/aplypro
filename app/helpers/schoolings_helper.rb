# frozen_string_literal: true

module SchoolingsHelper
  def attributive_decision_badge(schooling)
    success_badge(schooling.attributive_decision.attached?, "Décision d'attribution")
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
    string_start_date = if schooling.start_date.present?
                          format_date(schooling.start_date)
                        else
                          format_date(schooling.establishment.school_year_range.first)
                        end
    string_end_date = if schooling.max_end_date.present?
                        format_date(schooling.max_end_date)
                      else
                        format_date(schooling.establishment.school_year_range.last)
                      end
    "Les dates saisies doivent être comprises dans la durée de la scolarité de l'élève
      (entre le #{string_start_date} et le #{string_end_date})."
  end

  def disabled_buttons?(schooling)
    !current_user.can_validate? ||
      !schooling.attributive_decision.attached? ||
      schooling.abrogation_decision.attached? ||
      schooling.end_date.blank?
  end
end
