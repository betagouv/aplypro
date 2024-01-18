# frozen_string_literal: true

module ASP
  module Mappers
    class EnregistrementMapper
      attr_reader :payment

      def initialize(payment)
        @payment = payment
      end

      def id_enregistrement
        payment.student.id
      end
    end
  end
end
