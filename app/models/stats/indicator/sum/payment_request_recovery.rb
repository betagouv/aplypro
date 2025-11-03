# frozen_string_literal: true

module Stats
  module Indicator
    module Sum
      class PaymentRequestRecovery < Stats::Sum
        def initialize(start_year)
          # TODO
          super(
            column: "pfmps.amount",
            all: ASP::PaymentRequest
              .for_year(start_year)
              .joins(:pfmp)
              .joins(:asp_payment_request_transitions)
          )
        end

        def title
          "Mt OR"
        end

        def tooltip_key
          "stats.amount.payment_request_recovery"
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
