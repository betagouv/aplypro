# frozen_string_literal: true

module Reprocessor
  class PaymentRequestRejected < Reprocessor::PaymentRequest
    attr_reader :pfmp_ids

    def reprocess_ids!(pfmp_ids)
      @pfmp_ids = pfmp_ids

      process_payment_requests
    end

    private

    def process_payment_requests
      results = { success: 0, failure: 0, ready: 0 }

      pfmp_ids.each do |id|
        pfmp = Pfmp.find(id)
        p_r = PfmpManager.new(pfmp).create_new_payment_request!
        process_payment_request(p_r, results)
      rescue PfmpManager::ExistingActivePaymentRequestError, PfmpManager::PaidPfmpError
        Rails.logger.info("Skipping PFMP: #{id}")
        next
      end

      log_results(results)
      results
    end
  end
end
