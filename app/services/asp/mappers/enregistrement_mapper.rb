# frozen_string_literal: true

module ASP
  module Mappers
    class EnregistrementMapper
      attr_reader :payment_request

      def initialize(payment_request)
        @payment_request = payment_request
      end

      def id_enregistrement
        payment_request.id
      end

      def id_individu
        payment_request.student.asp_individu_id
      end
    end
  end
end
