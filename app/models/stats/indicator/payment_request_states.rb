# frozen_string_literal: true

module Stats
  module Indicator
    class PaymentRequestStates < Count
      STATE_FOR_TITLE = {
        sent: "envoyées",
        integrated: "intégrées",
        paid: "payées"
      }.freeze

      def initialize(start_year, state)
        @state = state

        super(
          all: ASP::PaymentRequest
            .for_year(start_year)
            .joins(:asp_payment_request_transitions)
            .where("asp_payment_request_transitions.to_state": state)
        )
      end

      def title
        "Demandes #{STATE_FOR_TITLE[@state]}"
      end

      def tooltip_key
        "stats.payment_request_#{@state}"
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
