# frozen_string_literal: true

class ConsiderPaymentRequestsJob < ApplicationJob
  queue_as :payments

  def perform
    requests = ASP::PaymentRequest.to_consider

    ActiveJob.perform_all_later(
      requests.map { |request| PreparePaymentRequestJob.new(request) }
    )
  end
end
