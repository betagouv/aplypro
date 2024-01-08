# frozen_string_literal: true

class Student
  module InfoMappers
    class Base
      attr_reader :payload

      def initialize(payload)
        @payload = payload
      end

      def attributes
        self.class::Mapper.new.call(payload)
      end
    end
  end
end
