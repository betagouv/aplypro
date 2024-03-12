# frozen_string_literal: true

module ApplicationHelper
  def success_badge(status, content)
    dsfr_badge(status: status ? :success : :error, classes: ["fr-badge--sm fr-mb-0"]) do
      content
    end
  end

  def status_count_badge(badge_method: nil, status: nil, status_string: nil, count: nil, **args)
    count ||= 0
    return if count.zero? && !args[:display_zero]

    count_tag = content_tag(:div, count, class: "fr-mr-1w")

    content_tag(:div, class: "fr-badge-group no-wrap #{args[:class]} fr-mb-1w", "aria-label": status_string) do
      safe_join([count_tag, send(badge_method, status)], " ")
    end
  end
end
