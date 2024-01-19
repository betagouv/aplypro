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
        "VERSE001"
      end

      def codetypeversement
        PAYMENT_TYPE_CODE
      end

      def mttotalfinancement
        payment.amount
      end

      # FIXME: this does a lot
      def usprinc
        ministry = payment.schooling.mef.ministry
        private_establishment = payment.schooling.establishment.private?

        BopMapper.to_unite_suivi(ministry:, private_establishment:)
      end
    end
  end
end
