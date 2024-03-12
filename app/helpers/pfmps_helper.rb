# frozen_string_literal: true

module PfmpsHelper
  def status_badge(status)
    status_level = PfmpDecorator::PFMP_STATE_MAPPING[status]
    dsfr_badge(status: status_level, classes: ["fr-badge"]) do
      t("pfmps.states.#{status}")
    end
  end

  def pfmp_badge(status, count, **args)
    count ||= 0
    return if count.zero? && !args[:display_zero]

    count_tag = content_tag(:div, count, class: "fr-mr-1w")

    content_tag(:div, class: "fr-badge-group no-wrap #{args[:class]}", "aria-label": t("pfmps.states.#{status}")) do
      safe_join([count_tag, status_badge(status)], " ")
    end
  end
end
