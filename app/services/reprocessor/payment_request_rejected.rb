# frozen_string_literal: true

module Reprocessor
  class PaymentRequestRejected < Reprocessor::PaymentRequest
    attr_reader :pfmp_ids

    def initialize(pfmp_ids)
      @pfmp_ids = pfmp_ids
    end

    def reprocess!
      results = process_payment_requests
      log_results(results)
      results
    end

    private

    def process_payment_requests
      results = { success: 0, failure: 0, ready: 0 }

      pfmp_ids.each do |id|
        pfmp = Pfmp.find(id)
        PfmpManager.new(pfmp).create_new_payment_request!
        process_payment_request(pfmp.latest_payment_request, results)
      end

      results
    end
  end
end
