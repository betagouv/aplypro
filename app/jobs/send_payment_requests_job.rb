# frozen_string_literal: true

class SendPaymentRequestsJob < ApplicationJob
  queue_as :payments

  sidekiq_options retry: false

  def perform(payment_requests)
    limit = [
      payment_requests.count,
      ASP::Request.total_requests_left,
      ASP::Request::MAX_RECORDS_PER_FILE
    ].min

    raise ASP::Errors::MaxRecordsPerWeekLimitReached if limit.zero?

    raise ASP::Errors::MaxRequestsPerDayLimitReached if ASP::Request.daily_requests_limit_reached?

    ActiveRecord::Base.transaction do
      ASP::Request
        .create!(asp_payment_requests: payment_requests.take(limit))
        .send!
    rescue Statesman::TransitionFailedError
      raise ASP::Errors::SendingPaymentRequestInWrongState
    end
  end
end
