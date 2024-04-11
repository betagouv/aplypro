# frozen_string_literal: true

module ASP
  module Readers
    class Base
      attr_reader :io, :record

      def initialize(str, record = nil)
        @io = handle_input(str)
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
