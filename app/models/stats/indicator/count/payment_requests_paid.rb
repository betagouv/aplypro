# frozen_string_literal: true

module Stats
  module Indicator
    module Count
      class PaymentRequestsPaid < Stats::Count
        def initialize(start_year)
          super(
            all: ASP::PaymentRequest
              .for_year(start_year)
              .joins(:asp_payment_request_transitions)
              .where("asp_payment_request_transitions.to_state": :paid)
          )
        end

        def self.key
          :payment_requests_paid_count
        end

        def self.title
          "Dem. payées"
        end

        def self.tooltip_key
          "stats.count.payment_request_paid"
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
