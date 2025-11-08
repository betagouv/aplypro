# frozen_string_literal: true

module Stats
  module Indicator
    module Sum
      class PaymentRequestsRecovery < Stats::Sum
        def initialize(start_year)
          super(
            column: "pfmps.amount",
            all: ASP::PaymentRequest.for_year(start_year)
                                    .joins(:pfmp)
                                    .joins(:asp_payment_request_transitions)
                                    .where(asp_payment_request_transitions: { most_recent: true })
                                    .where("asp_payment_request_transitions.metadata LIKE ?", "%ORDREREVERSEMENT%")
          )
        end

        def self.key
          :payment_requests_recovery_sum
        end

        def self.title
          "Mt. OR"
        end

        def self.tooltip_key
          "stats.sum.payment_request_recovery"
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
