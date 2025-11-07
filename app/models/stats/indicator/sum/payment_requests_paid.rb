# frozen_string_literal: true

module Stats
  module Indicator
    module Sum
      class PaymentRequestsPaid < Stats::Sum
        def initialize(start_year)
          super(
            column: "pfmps.amount",
            all: ASP::PaymentRequest
              .for_year(start_year)
              .joins(:pfmp)
              .joins(:asp_payment_request_transitions)
              .where("asp_payment_request_transitions.to_state": :paid)
          )
        end

        def self.key
          :payment_requests_paid_sum
        end

        def self.title
          "Mt. payé"
        end

        def self.tooltip_key
          "stats.sum.payment_request_paid"
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
