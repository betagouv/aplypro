# frozen_string_literal: true

module PaymentRequestsHelper
  def payment_request_status_badge(status)
    status_level = ASP::PaymentRequestDecorator::BADGE_STATE_MAPPING[status]
    dsfr_badge(status: status_level, classes: ["fr-badge--sm"]) do
      t("payment_requests.state.#{status}")
    end
  end

  def payment_requests_status_count_badge(status, count, **args)
    status_count_badge(
      badge_method: :payment_request_status_badge,
      status: status,
      status_string: t("payment_requests.state.#{status}"),
      count: count,
      **args
    )
  end
end
