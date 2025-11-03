# frozen_string_literal: true

module Stats
  module Indicator
    module Count
      class PfmpsPayable < Stats::Count
        def initialize(start_year)
          pfmps = Pfmp.for_year(start_year)

          super(
            all: pfmps.in_state(:validated)
          )
        end

        def title
          "Nb PFMPs payables"
        end

        def tooltip_key
          "stats.count.pfmps_payable"
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
