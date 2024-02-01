# frozen_string_literal: true

module ClassesHelper
  def ribs_progress_badge(schoolings)
    count = schoolings.joins(student: :rib).count
    total = schoolings.size

    progress_badge(count, total)
  end

  def attributive_decisions_progress_badge(schoolings)
    count = schoolings.with_attributive_decisions.count
    total = schoolings.size

    progress_badge(count, total)
  end

  def nb_pfmps(schoolings)
    schoolings.joins(:pfmps).count(:"pfmps.id")
  end

  def closed_schooling_information_tag(schooling, **args)
    return if schooling.blank? || schooling.open?

    content_tag(
      :div,
      "Sorti(e) de la classe",
      class: "fr-badge fr-badge--sm fr-badge--warning #{args[:class]}"
    )
  end
end
