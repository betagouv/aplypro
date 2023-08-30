# frozen_string_literal: true

module PfmpDecorator
  PFMP_STATE_MAPPING = {
    pending: :new,
    completed: :info,
    validated: :success
  }.freeze

  def status_badge
    label = t("pfmps.state.#{current_state}")

    dsfr_badge(status: PFMP_STATE_MAPPING[current_state.to_sym]) { label }
  end
end
