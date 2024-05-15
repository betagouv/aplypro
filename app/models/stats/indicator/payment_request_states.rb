# frozen_string_literal: true

module Stats
  module Indicator
    class PaymentRequestStates < Count
      STATE_FOR_TITLE = {
        sent: "envoyées à l'ASP",
        integrated: "intégrées par l'ASP",
        paid: "payées par l'ASP"
      }.freeze

      def initialize(state)
        @state = state

        super(
          all: ASP::PaymentRequest
            .joins(:asp_payment_request_transitions)
            .where("asp_payment_request_transitions.to_state": state)
        )
      end

      def title
        "Demandes de paiement #{STATE_FOR_TITLE[@state]}"
      end

      def with_mef_and_establishment
        ASP::PaymentRequest.joins(schooling: { classe: %i[mef establishment] })
      end

      def with_establishment
        ASP::PaymentRequest.joins(schooling: { classe: :establishment })
      end
    end
  end
end
