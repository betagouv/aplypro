# frozen_string_literal: true

module ASP
  module Mappers
    class ElementPaiementMapper
      PAYMENT_TYPE_CODE = "PAIEMENT"

      attr_reader :payment_request

      def initialize(payment_request)
        @payment_request = payment_request
      end

      def objetecheance
        payment_request.pfmp.start_date.strftime("%Y%m")
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
