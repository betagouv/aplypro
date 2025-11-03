# frozen_string_literal: true

module Stats
  module Indicator
    module Sum
      class PaymentRequestsStates < Stats::Sum
        STATE_FOR_TITLE = {
          sent: "envoyé",
          integrated: "intégré",
          paid: "payé"
        }.freeze

        def initialize(start_year, state)
          @state = state

          super(
            column: "pfmps.amount",
            all: ASP::PaymentRequest
              .for_year(start_year)
              .joins(:pfmp)
              .joins(:asp_payment_request_transitions)
              .where("asp_payment_request_transitions.to_state": state)
          )
        end

        def title
          "Mt #{STATE_FOR_TITLE[@state]}"
        end

        def tooltip_key
          "stats.amount.payment_request_#{@state}"
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
end
