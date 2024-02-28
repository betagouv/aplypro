# frozen_string_literal: true

module ASP
  module Mappers
    class ElementPaiementMapper
      PAYMENT_TYPE_CODE = "PAIEMENT"

      attr_reader :payment_request

      def initialize(payment_request)
        @payment_request = payment_request
      end

      def codeobjet
        index = payment_request.pfmp.payment_requests.find_index { |p| p == payment_request }

        "VERSE00#{index + 1}"
      end

      def codetypeversement
        PAYMENT_TYPE_CODE
      end

      def mttotalfinancement
        payment_request.pfmp.amount
      end

      def usprinc
        code = payment_request.schooling.bop_code

        ENV.fetch("APLYPRO_ASP_#{code.upcase}_UNITE_SUIVI")
      end
    end
  end
end
