# frozen_string_literal: true

class SendPaymentsJob < ApplicationJob
  queue_as :default

  def perform(payment_ids)
    requests = ASP::PaymentRequest
               .in_state(:ready)
               .where(payment: payment_ids)

    ASP::Request
      .create!(asp_payment_requests: requests)
      .send!
  end
end
