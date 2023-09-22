# frozen_string_literal: true

module IdentityMappers
  module Errors
    class Error < StandardError; end

    class OmniauthError < Error
      def initialize(msg = "Omniauth failed without an exception")
        super(msg)
      end
    end

    class EmptyResponsibilitiesError < Error
      attr_reader :attributes

      def initialize(msg = "No responsibilites indicated", attributes = {})
        @attributes = attributes

        super(msg)
      end
    end
  end
end
