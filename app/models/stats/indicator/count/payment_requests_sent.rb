# frozen_string_literal: true

module Stats
  module Indicator
    module Count
      class PaymentRequestsSent < Stats::Count
        def initialize(start_year)
          super(
            all: ASP::PaymentRequest
              .for_year(start_year)
              .joins(:asp_payment_request_transitions)
              .where("asp_payment_request_transitions.to_state": :sent)
          )
        end

        def self.key
          :payment_requests_sent_count
        end

        def self.title
          "Dem. envoyées"
        end

        def self.tooltip_key
          "stats.count.payment_request_sent"
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
