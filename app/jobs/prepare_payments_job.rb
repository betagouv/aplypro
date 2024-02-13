# frozen_string_literal: true

class PreparePaymentsJob < ApplicationJob
  queue_as :default

  def perform
    ASP::PaymentRequest
      .in_state(:pending)
      .find_each do |request|
      request.mark_ready!
    rescue Statesman::GuardFailedError
      request.mark_incomplete!
    end
  end
end
