# frozen_string_literal: true

module HomeHelper
  def indicator_badge(count, total)
    status = indicator_badge_status(count, total)

    dsfr_badge(status: status, classes: ["fr-badge"]) do
      "#{count} / #{total}"
    end
  end

  def indicator_badge_status(count, total)
    if total.zero?
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

  def status_badge(status)
    status_level = PfmpDecorator::PFMP_STATE_MAPPING[status]
    dsfr_badge(status: status_level, classes: ["fr-badge"]) do
      t("pfmps.states.#{status}")
    end
  end

  def pfmp_badge(state, pfmps_counts)
    count_tag = content_tag(:div, class: "fr-mr-1w") do
      pfmps_counts[state.to_s].to_s
    end

    [
      count_tag,
      status_badge(state)
    ].join("\n")
  end
end
