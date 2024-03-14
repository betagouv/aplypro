# frozen_string_literal: true

module PfmpsHelper
  def pfmp_status_badge(status, **args)
    status_level = PfmpDecorator::PFMP_STATE_MAPPING[status]

    dsfr_badge(status: status_level, classes: ["fr-m-0"].push(args[:class])) do
      t("pfmps.states.#{status}")
    end
  end

  def pfmps_status_count_badge(status, count, **args)
    status_count_badge(
      badge_method: :pfmp_status_badge,
      status: status,
      status_string: t("pfmps.states.#{status}"),
      count: count,
      **args
    )
  end
end
