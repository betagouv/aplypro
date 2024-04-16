# frozen_string_literal: true

class SendPaymentRequestsJob < ApplicationJob
  queue_as :default

  sidekiq_options retry: 0

  def perform(payment_requests)
    limit = [ASP::Request.total_requests_left, payment_requests.count].min

    raise ASP::Errors::MaxRecordsPerWeekLimitReached if limit.zero?

    raise ASP::Errors::MaxRequestsPerDayLimitReached if ASP::Request.daily_requests_limit_reached?

    ActiveRecord::Base.transaction do
      ASP::Request
        .create!(asp_payment_requests: payment_requests.first(limit))
        .send!
    rescue Statesman::TransitionFailedError
      raise ASP::Errors::SendingPaymentRequestInWrongState
    end
  end
end
