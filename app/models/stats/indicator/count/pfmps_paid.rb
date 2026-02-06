# frozen_string_literal: true

module Stats
  module Indicator
    module Count
      class PfmpsPaid < Stats::Count
        def initialize(start_year)
          super(
            all: Pfmp.for_year(start_year).joins(payment_requests: :asp_payment_request_transitions)
                 .where(asp_payment_request_transitions: { most_recent: true, to_state: "paid" })
                 .distinct
          )
        end

        def self.key
          :pfmps_paid_count
        end

        def self.title
          "Nb. PFMPs payées"
        end

        def self.tooltip_key
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
