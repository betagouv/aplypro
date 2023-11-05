# frozen_string_literal: true

class Student
  module AddressMappers
    class Base
      attr_reader :payload

      def initialize(payload)
        @payload = payload
      end

      def address_attributes
        self.class::ADDRESS_MAPPING.transform_values do |path|
          payload.dig(*path.split("."))
        end
      end
    end
  end
end
