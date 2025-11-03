# frozen_string_literal: true

module Stats
  module Indicator
    module Count
      class PfmpsPaid < Stats::Count
        def initialize(start_year)
          pfmp = Pfmp.for_year(start_year)

          super(
            all: pfmp.joins(:payment_requests)
                     .merge(ASP::PaymentRequest.in_state(:paid))
                     .distinct
          )
        end

        def key
          :pfmps_paid_count
        end

        def title
          "Nb. PFMPs payées"
        end

        def tooltip_key
          "stats.count.pfmps_paid"
        end

        def with_mef_and_establishment
          Pfmp.joins(schooling: { classe: %i[mef establishment] })
        end

        def with_establishment
          Pfmp.joins(schooling: { classe: :establishment })
        end
      end
    end
  end
end
