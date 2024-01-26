# frozen_string_literal: true

module PaymentDecorator
  BADGE_STATE_MAPPING = {
    ready: :success,
    blocked: :error,
    pending: :info
  }.freeze

  def summary
    dsfr_badge(status: BADGE_STATE_MAPPING[current_state.to_sym]) do
      status
    end
  end

  def status
    t("payments.state.#{current_state}")
  end

  def description
    t("payments.description.#{current_state}")
  end
end
