# frozen_string_literal: true

module ASP
  module Readers
    class Base
      include Enumerable

      attr_reader :io, :record

      def initialize(io:, record: nil)
        @io = handle_input(io)
        @record = record
      end

      def handle_input(str)
        str.strip
      end

      def process!
        raise NotImplementedError
      end
    end
  end
end
