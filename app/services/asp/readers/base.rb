# frozen_string_literal: true

module ASP
  module Readers
    class Base
      attr_reader :io

      def initialize(str)
        @io = handle_input(str)
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
