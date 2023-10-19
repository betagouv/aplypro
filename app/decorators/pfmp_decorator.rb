# frozen_string_literal: true

module PfmpDecorator
  PFMP_STATE_MAPPING = {
    pending: :new,
    completed: :info,
    validated: :success
  }.freeze

  def status_badge
    dsfr_badge(status: PFMP_STATE_MAPPING[current_state.to_sym], classes: ["fr-badge--sm"]) do
      status_to_s
    end
  end

  def status_to_s
    t("pfmps.state.#{current_state}")
  end

  def all_status_badges
    t("pfmps.state").map do |status_key, status_string|
      is_disabled = current_state.to_sym == status_key ? "" : "is_disabled"
      dsfr_badge(status: PFMP_STATE_MAPPING[status_key], classes: ["fr-badge--sm", is_disabled]) do
        status_string
      end
    end
  end

  def listing_to_s
    [
      status_badge,
      [
        l(start_date, format: :pfmp_listing),
        l(end_date, format: :pfmp_listing)
      ].uniq.join(" - ")
    ].join(" ").html_safe
  end
end
