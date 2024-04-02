# frozen_string_literal: true

class Student
  module InfoMappers
    class Base
      attr_reader :payload, :uai

      def initialize(payload, uai)
        @payload = payload
        @uai = uai
      end

      def attributes
        self.class::Mapper.new.call(payload)
      end

      def schooling_attributes
        self.class::SchoolingMapper.new.call(payload)
      end
    end
  end
end
