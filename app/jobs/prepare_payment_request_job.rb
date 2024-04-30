# frozen_string_literal: true

class PreparePaymentRequestJob < ApplicationJob
  queue_as :payments

  sidekiq_options retry: false

  retry_on Faraday::UnauthorizedError, wait: 1.second, attempts: 10

  def perform(payment_request)
    FetchStudentInformationJob.perform_now(payment_request.schooling)

    payment_request.mark_ready!
  end
end
