# frozen_string_literal: true

class SendPaymentRequestsJob < ApplicationJob
  queue_as :default

  def perform(payment_requests)
    ASP::Request
      .create!(asp_payment_requests: payment_requests)
      .send!
  rescue Statesman::TransitionFailedError
    raise ASP::Errors::SendingPaymentRequestInWrongState
  end
end
