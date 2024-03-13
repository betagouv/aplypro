# frozen_string_literal: true

module PaymentRequestsHelper
  def payment_request_status_badge(status, **args)
    status_level = ASP::PaymentRequestDecorator::BADGE_STATE_MAPPING[status]
    dsfr_badge(status: status_level, classes: %w[fr-badge--sm fr-m-0].push(args[:class])) do
      t("payment_requests.states.#{status}")
    end
  end

  def payment_requests_status_count_badge(status, count, **args)
    status_count_badge(
      badge_method: :payment_request_status_badge,
      status: status,
      status_string: t("payment_requests.states.#{status}"),
      count: count,
      **args
    )
  end
end
