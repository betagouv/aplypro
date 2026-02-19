# frozen_string_literal: true

module ASP
  module Errors
    class Error < ::StandardError; end
    class ResponseFileParsingError < Error; end
    class UnmatchedResponseFile < Error; end
    class SendingPaymentRequestInWrongState < Error; end
    class RerunningParsedRequest < Error; end
    class MaxRecordsPerWeekLimitReached < Error; end
    class MaxRequestsPerDayLimitReached < Error; end
    class IncompletePaymentRequestError < Error; end
    class FundingNotAvailableError < Error; end
    class NegativeRectificationError < Error; end
    class MissingEstablishmentCommuneCodeError < Error; end
    class MissingEstablishmentPostalCodeError < Error; end
    class PaymentFileValidationError < Error; end
    class ReadingFileError < Error; end

    class IntegrationError < Error
      attr_reader :payment_request

      def initialize(message, payment_request)
        @payment_request = payment_request
        super(message)
      end
    end
  end
end
