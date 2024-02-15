# frozen_string_literal: true

module ASP
  module Readers
    class Base
      attr_reader :io

      def initialize(io)
        @io = io.strip
      end

      def process!
        raise NotImplementedError
      end
    end
  end
end
