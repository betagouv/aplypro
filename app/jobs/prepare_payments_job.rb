# frozen_string_literal: true

class PreparePaymentsJob < ApplicationJob
  queue_as :default

  def perform
    Payment
      .includes(:student)
      .in_state(:pending)
      .find_each do |payment|
      payment.mark_ready!
    rescue Statesman::GuardFailedError
      payment.block!
    end
  end
end
