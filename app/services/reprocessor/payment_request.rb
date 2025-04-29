# frozen_string_literal: true

module Reprocessor
  class PaymentRequest
    private

    def process_payment_requests
      raise "this method should be overriden"
    end

    def process_payment_request(payment_request, results)
      Rails.logger.info("processing p_r #{payment_request.id}")

      if attempt_ready_transition(payment_request)
        results[:success] += 1
        results[:ready] += 1 if payment_request.reload.in_state?(:ready)
      else
        results[:failure] += 1
      end
    end

    def attempt_ready_transition(payment_request)
      payment_request.mark_ready!
    rescue Statesman::TransitionFailedError
      false
    end

    def log_results(results)
      total = results[:success] + results[:failure]

      Rails.logger.info(
        "Reprocessed #{total} payment requests. " \
        "Success: #{results[:success]}, Ready: #{results[:ready]}, " \
        "Failed: #{results[:failure]}"
      )
    end
  end
end
