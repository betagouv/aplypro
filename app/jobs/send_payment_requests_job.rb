# frozen_string_literal: true

class SendPaymentRequestsJob < ApplicationJob
  queue_as :default

  def perform(payment_ids)
    requests = ASP::PaymentRequest
               .joins(ASP::PaymentRequest.most_recent_transition_join)
               .where(payment: payment_ids)

    raise ASP::Errors::SendingPaymentRequestInWrongState if requests.any? { |req| !req.in_state?(:ready) }

    ASP::Request
      .create!(asp_payment_requests: requests)
      .send!
  end
end
