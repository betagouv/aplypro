# frozen_string_literal: true

module IdentityMappers
  module Errors
    class Error < ::StandardError; end

    class OmniauthError < Error
      def initialize(msg = "Omniauth failed without an exception")
        super
      end
    end

    class EmptyResponsibilitiesError < Error
      attr_reader :attributes

      def initialize(msg = "No responsibilites indicated", attributes = {})
        @attributes = attributes

        super(msg)
      end
    end

    class NotAuthorisedError < Error
      attr_reader :attributes

      def initialize(msg = "No delegations indicated")
        super
      end
    end

    class NoAccessFound < Error
      attr_reader :attributes

      def initialize(msg = "No access conclusion")
        super
      end
    end

    class NoLimitedAccessError < Error
      attr_reader :attributes

      def initialize(msg = "Not allowed in the private beta")
        super
      end
    end

    class UnallowedPrivateEstablishment < Error
      attr_reader :attributes

      def initialize(msg = "The private establishment is not included in the reform")
        super
      end
    end
  end
end
