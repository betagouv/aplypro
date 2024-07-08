# frozen_string_literal: true

class PreparePaymentRequestJob < ApplicationJob
  include FregataProof

  def perform(payment_request)
    Sync::StudentJob.perform_now(payment_request.schooling)

    payment_request.mark_ready!
  end
end
