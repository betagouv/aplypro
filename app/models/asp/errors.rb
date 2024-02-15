# frozen_string_literal: true

module ASP
  module Errors
    class Error < ::StandardError; end
    class UnmatchedResponseFile < Error; end
  end
end
