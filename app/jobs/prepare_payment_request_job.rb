# frozen_string_literal: true

class PreparePaymentRequestJob < ApplicationJob
  queue_as :payments

  sidekiq_options retry: false

  retry_on Faraday::UnauthorizedError, wait: 1.second, attempts: 10

  def perform(payment_request)
    FetchStudentInformationJob.perform_now(payment_request.schooling)

    begin
      payment_request.mark_ready!
    rescue Statesman::GuardFailedError
      # FIXME: arguably this could leverage the
      # after_transition_failure API from statesman but we need to
      # understand whether mark_ready! should *always* make a request
      # incomplete if it couldn't be readied.
      payment_request.mark_incomplete!
    end
  end
end
