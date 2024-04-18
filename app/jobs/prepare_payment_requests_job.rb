# frozen_string_literal: true

class PreparePaymentRequestsJob < ApplicationJob
  queue_as :default

  def perform
    ASP::PaymentRequest
      .in_state(:pending)
      .find_each do |request|
      if request.can_transition_to?(:ready)
        request.mark_ready!
      else
        request.mark_incomplete!
      end
    end
  end
end
