# frozen_string_literal: true

module PaymentRequests
  class UnfreezePendingForFundingJob < ApplicationJob
    queue_as :payments

    def perform(ministry = nil)
      unfrozen = ApplicationRecord.transaction do
        pending_requests_for_funding(ministry).find_each.count(&:mark_ready!)
      end

      Rails.logger.info "Unfroze #{unfrozen} pending payment #{'request'.pluralize(unfrozen)} for funding"
    end

    private

    def pending_requests_for_funding(ministry)
      scope = ASP::PaymentRequest
              .joins(:asp_payment_request_transitions)
              .where(asp_payment_request_transitions: { most_recent: true, to_state: "pending" })
              .where(
                "asp_payment_request_transitions.metadata::jsonb ->> 'pending_reason' = ?",
                ASP::PaymentRequest::FUNDING_ISSUE
              )

      scope = scope.for_ministry(ministry) if ministry.present?

      scope
    end
  end
end
