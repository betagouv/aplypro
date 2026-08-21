# frozen_string_literal: true

class RetryUnpaidTresorerieJob < ApplicationJob
  queue_as :payments

  RETRY_WINDOW = 4.months

  def perform(ministry = nil)
    retried = pfmps_to_retry(ministry).count { |pfmp| PfmpManager.new(pfmp).retry_payment_request! }

    Rails.logger.info "Retried #{retried} unpaid trésorerie payment requests"
  end

  private

  def pfmps_to_retry(ministry)
    Pfmp.where(id: unpaid_tresorerie_requests(ministry).map(&:pfmp_id))
        .includes(payment_requests: :asp_payment_request_transitions)
        .reject(&:paid?)
  end

  def unpaid_tresorerie_requests(ministry)
    scope = ASP::PaymentRequest
            .joins(:asp_payment_request_transitions)
            .where(asp_payment_request_transitions: { most_recent: true,
                                                      to_state: "unpaid",
                                                      created_at: RETRY_WINDOW.ago.. })

    scope = scope.for_ministry(ministry) if ministry.present?

    scope.select(&:unpaid_tresorerie?)
  end
end
