# frozen_string_literal: true

module IdentityMappers
  module Errors
    class EmptyResponsibilitiesError < StandardError
      attr_reader :attributes

      def initialize(msg = "No responsibilites indicated", attributes = {})
        @attributes = attributes

        super(msg)
      end
    end
  end
end
