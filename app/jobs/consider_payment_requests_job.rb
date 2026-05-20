# frozen_string_literal: true

class ConsiderPaymentRequestsJob < ApplicationJob
  queue_as :payments

  def perform
    ActiveJob.perform_all_later(
      ASP::PaymentRequest.to_consider.map { |request| PreparePaymentRequestJob.new(request) }
    )
  end
end
