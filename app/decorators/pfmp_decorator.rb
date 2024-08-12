# frozen_string_literal: true

module PfmpDecorator
  delegate :index_name, to: :student, prefix: true

  PFMP_STATE_MAPPING = {
    pending: :new,
    completed: :info,
    validated: :success,
    rectified: :error
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
      disabled = current_state.to_sym == status_key ? "" : "disabled"
      dsfr_badge(status: PFMP_STATE_MAPPING[status_key], classes: ["fr-badge--sm", disabled]) do
        status_string
      end
    end
  end

  def listing_to_s
    safe_join([status_badge, " ", formatted_dates])
  end

  def formatted_dates
    [
      l(start_date, format: :pfmp_listing),
      l(end_date, format: :pfmp_listing)
    ].uniq.join(" - ")
  end

  def full_dates
    [
      l(start_date),
      l(end_date)
    ].uniq.join(" - ")
  end
end
