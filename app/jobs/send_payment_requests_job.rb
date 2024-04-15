# frozen_string_literal: true

class SendPaymentRequestsJob < ApplicationJob
  queue_as :default

  discard_on ASP::Errors::XMLValidationFailed

  def perform(payment_requests)
    ActiveRecord::Base.transaction do
      ASP::Request
        .create!(asp_payment_requests: payment_requests)
        .send!
    rescue Statesman::TransitionFailedError
      raise ASP::Errors::SendingPaymentRequestInWrongState
    end
  end
end
