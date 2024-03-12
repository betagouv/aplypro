# frozen_string_literal: true

module PaymentRequestsHelper
  def payment_request_status_badge(status)
    status_level = ASP::PaymentRequestDecorator::BADGE_STATE_MAPPING[status]
    dsfr_badge(status: status_level, classes: ["fr-badge--sm"]) do
      t("payment_requests.state.#{status}")
    end
  end
end
