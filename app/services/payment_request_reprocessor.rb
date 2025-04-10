# frozen_string_literal: true

class PaymentRequestReprocessor
  class PaymentRequestReprocessorError < StandardError; end
  class InvalidReasonError < PaymentRequestReprocessorError; end

  attr_reader :reason_key, :ministry

  def initialize(reason_key, ministry: nil)
    @reason_key = reason_key
    @ministry = ministry
    validate_reason!
  end

  def reprocess!
    results = process_payment_requests
    log_results(results)
    results
  end

  private

  def process_payment_requests
    results = { success: 0, failure: 0, ready: 0 }

    incomplete_requests.find_each do |payment_request|
      process_payment_request(payment_request, results)
    end

    results
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
