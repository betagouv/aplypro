# frozen_string_literal: true

module ASP
  module Mappers
    class ElementPaiementMapper
      PAYMENT_TYPE_CODE = "PAIEMENT"

      attr_reader :payment

      def initialize(payment_request)
        @payment = payment_request.payment
      end

      def codeobjet
        index = payment.pfmp.payments.find_index { |p| p == payment }

        "VERSE00#{index + 1}"
      end

      def codetypeversement
        PAYMENT_TYPE_CODE
      end

      def mttotalfinancement
        payment.amount
      end

      def usprinc
        code = payment.schooling.bop_code

        ENV.fetch("APLYPRO_ASP_#{code.upcase}_UNITE_SUIVI")
      end
    end
  end
end
