# frozen_string_literal: true

module ASP
  module Readers
    module Errors
      class Error < StandardError; end
      class ReadOnlyMode < Error; end
    end
  end
end
