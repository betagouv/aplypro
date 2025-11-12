# frozen_string_literal: true

module Stats
  module Indicator
    module Count
      class PaymentRequestsPaid < Stats::Count
        def initialize(start_year)
          super(
            all: ASP::PaymentRequest
              .for_year(start_year)
              .in_state(:paid)
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
          ASP::PaymentRequest.joins(schooling: { classe: %i[mef establishment school_year] })
        end

        def with_establishment
          ASP::PaymentRequest.joins(schooling: { classe: %i[establishment school_year] })
        end
      end
    end
  end
end
