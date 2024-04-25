# frozen_string_literal: true

class PreparePaymentRequestsJob < ApplicationJob
  queue_as :payments

  def perform
    ASP::PaymentRequest
      .in_state(:pending)
      .find_each(&:attempt_transition_to_ready!)
  end
end
