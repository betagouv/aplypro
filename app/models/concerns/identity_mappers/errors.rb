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

    class NotAuthorisedError < Error
      attr_reader :attributes

      def initialize(msg = "No delegations indicated")
        super(msg)
      end
    end

    class NoLimitedAccessError < Error
      attr_reader :attributes

      def initialize(msg = "Not allowed in the private beta")
        super(msg)
      end
    end

    class UnallowedPrivateEstablishment < Error
      attr_reader :attributes

      def initialize(msg = "The private establishment is not included in the reform")
        super(msg)
      end
    end
  end
end
