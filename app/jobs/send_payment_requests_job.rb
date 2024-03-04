# frozen_string_literal: true

class SendPaymentRequestsJob < ApplicationJob
  queue_as :default

  def perform(payment_requests)
    requests = ASP::PaymentRequest
               .joins(ASP::PaymentRequest.most_recent_transition_join)
               .where(id: payment_requests)

    raise ASP::Errors::SendingPaymentRequestInWrongState if requests.any? { |req| !req.in_state?(:ready) }

    ASP::Request
      .create!(asp_payment_requests: requests)
      .send!
  end
end
