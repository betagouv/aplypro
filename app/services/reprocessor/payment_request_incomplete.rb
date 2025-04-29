# frozen_string_literal: true

module Reprocessor
  class PaymentRequestIncompleteError < StandardError; end
  class InvalidReasonError < PaymentRequestIncompleteError; end

  class PaymentRequestIncomplete < Reprocessor::PaymentRequest
    attr_reader :reason_key, :ministry

    def reprocess_all!(reason_key, ministry: nil)
      @reason_key = reason_key
      @ministry = ministry
      validate_reason!

      process_payment_requests
    end

    private

    def process_payment_requests
      results = { success: 0, failure: 0, ready: 0 }

      incomplete_requests.find_each do |payment_request|
        process_payment_request(payment_request, results)
      end

      log_results(results)
      results
    end

    def validate_reason!
      return if validation_message.present?

      raise InvalidReasonError, "No validation message found for reason key: #{reason_key}"
    end

    def validation_message
      I18n.t(
        "activerecord.errors.models.asp/payment_request.attributes.ready_state_validation.#{reason_key}",
        default: nil
      )
    end

    def incomplete_requests
      base_scope = ASP::PaymentRequest.in_state(:incomplete).where(
        "metadata LIKE ?",
        "%\"incomplete_reasons\":{\"ready_state_validation\":[\"#{validation_message}\"]%"
      )

      if ministry
        base_scope.joins(pfmp: { classe: :mef })
                  .where(mefs: { ministry: ministry })
      else
        base_scope
      end
    end
  end
end
