# frozen_string_literal: true

module PaymentRequestsHelper
  def payment_request_status_badge(status, **args)
    status_level = ASP::PaymentRequestDecorator::BADGE_STATE_MAPPING[status]

    dsfr_badge(status: status_level, html_attributes: { class: %w[fr-badge--sm fr-m-0].push(args[:class]) }) do
      t("payment_requests.states.#{status}")
    end
  end

  def payment_requests_status_count_badge(status, count, **args)
    aria_label = "Demande de paiement #{t("payment_requests.states.#{status}")}"

    status_count_badge(
      badge_method: :payment_request_status_badge,
      status: status,
      aria_label: aria_label,
      count: count,
      **args
    )
  end
end
