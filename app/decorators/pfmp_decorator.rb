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

  def listing_to_s
    [
      status_badge,
      [l(start_date), l(end_date)].join(" - ")
    ].join(" ").html_safe
  end
end
