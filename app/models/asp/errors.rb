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
  end
end
