# frozen_string_literal: true

module Stats
  module Indicator
    module Count
      class PaymentRequestsStates < Stats::Count
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

        def key
          :"payment_requests_#{@state}_count"
        end

        def title
          "Dem. #{STATE_FOR_TITLE[@state]}"
        end

        def tooltip_key
          "stats.count.payment_request_#{@state}"
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
