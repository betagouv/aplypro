# frozen_string_literal: true

module Stats
  module Indicator
    class PaymentRequestStateAmounts < Sum
      STATE_FOR_TITLE = {
        sent: "envoyé à l'ASP",
        integrated: "intégré par l'ASP",
        paid: "payé par l'ASP"
      }.freeze

      def initialize(state)
        @state = state

        super(
          column: "pfmps.amount",
          all: ASP::PaymentRequest
            .for_year($start_year)
            .joins(:pfmp)
            .joins(:asp_payment_request_transitions)
            .where("asp_payment_request_transitions.to_state": state)
        )
      end

      def title
        "Montant #{STATE_FOR_TITLE[@state]}"
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
