# frozen_string_literal: true

class ConsiderPaymentRequestsJob < ApplicationJob
  queue_as :payments

  def perform(max_date)
    requests = ASP::PaymentRequest.to_consider(max_date)

    ActiveJob.perform_all_later(
      requests.map { |request| PreparePaymentRequestJob.new(request) }
    )
  end
end
