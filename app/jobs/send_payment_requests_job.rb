# frozen_string_literal: true

class SendPaymentRequestsJob < ApplicationJob
  queue_as :payments

  sidekiq_options retry: false

  def perform # rubocop:disable Metrics/AbcSize
    return unless ActiveModel::Type::Boolean.new.cast(ENV.fetch("APLYPRO_OUTGOING_PAYMENTS_ENABLED"))

    payment_requests = ASP::PaymentRequest.in_state(:ready).order(created_at: :asc)

    return if payment_requests.none?

    limit = [
      payment_requests.count,
      ASP::Request.total_payment_requests_left,
      ASP::Request::MAX_RECORDS_PER_FILE
    ].min

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
