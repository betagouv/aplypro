# frozen_string_literal: true

module ASP
  module Mappers
    class ElementPaiementMapper
      PAYMENT_TYPE_CODE = "PAIEMENT"

      attr_reader :payment

      def initialize(payment)
        @payment = payment
      end

      def codeobjet
        existing = payment
                   .student
                   .payments
                   .in_state(:successful)
                   .count

        "VERSE00#{existing + 1}"
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
