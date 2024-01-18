# frozen_string_literal: true

module ASP
  module Mappers
    class EnregistrementMapper
      MAPPING = {
      }.freeze

      attr_reader :payment

      def initialize(payment)
        @payment = payment
      end

      MAPPING.each do |name, attr|
        define_method(name) { schooling.send(attr) }
      end

      def idEnregistrement
        payment.student.id
      end
    end
  end
end
