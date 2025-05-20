# frozen_string_literal: true

module ClassesHelper
  def ribs_progress_badge(schoolings, **args)
    schoolings = schoolings.without_removed_students

    count = schoolings.joins(student: :ribs)
                      .where(ribs: { archived_at: nil, establishment: current_establishment })
                      .distinct(:"students.id")
                      .count(:"students.id")

    total = schoolings.select(:student_id).distinct.count

    progress_badge(count, total, **args)
  end

  def attributive_decisions_progress_badge(schoolings, **args)
    count = schoolings.with_attributive_decisions.count
    total = schoolings.without_removed_students.size

    progress_badge(count, total, **args)
  end

  def nb_pfmps(schoolings)
    schoolings.joins(:pfmps).count(:"pfmps.id")
  end

  def closed_schooling_information_tag(schooling, **args)
    return if schooling.blank?

    if schooling.removed?
      content_tag(
        :div,
        "Masqué(e) manuellement de la classe",
        class: "fr-badge fr-badge--sm fr-badge--warning #{args[:class]}"
      )
    elsif schooling.closed?
      content_tag(
        :div,
        "Sorti(e) de la classe",
        class: "fr-badge fr-badge--sm fr-badge--warning #{args[:class]}"
      )
    end
  end

  def extended_end_date_information_tag(schooling, **args)
    return if schooling.blank? || schooling.extended_end_date.blank?

    content_tag(
      :div,
      "Date de report : #{format_date(schooling.extended_end_date)}",
      class: "fr-badge fr-badge--sm fr-badge--info #{args[:class]}"
    )
  end

  private

  def progress_badge(count, total, **args)
    count ||= 0
    status = progress_badge_status(count, total)

    content_tag(:div, title: args[:title]) do
      dsfr_badge(status: status, classes: ["fr-badge counter"]) do
        "#{count} / #{total}"
      end
    end
  end

  def progress_badge_status(count, total)
    if total.nil? || total.zero?
      :error
    else
      case count / total
      when 0..0.5
        :error
      when 0.51..0.99
        :warning
      when 1
        :success
      end
    end
  end
end
