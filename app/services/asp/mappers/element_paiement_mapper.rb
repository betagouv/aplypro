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
        # we don't support multiple payments per PFMP yet.
        "VERSE001"
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
