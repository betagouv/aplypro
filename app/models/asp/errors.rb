# frozen_string_literal: true

module ASP
  module Errors
    class Error < ::StandardError; end
    class ResponseFileParsingError < Error; end
    class UnmatchedResponseFile < Error; end
    class SendingPaymentRequestInWrongState < Error; end
    class RerunningParsedRequest < Error; end
  end
end
