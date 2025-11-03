# frozen_string_literal: true

module Stats
  module Indicator
    module Count
      class PfmpsReport < Stats::Count
        def initialize(start_year)
          # TODO
          super(
            all: Pfmp.for_year(start_year)
          )
        end

        def key
          :pfmps_report_count
        end

        def title
          "Nb. PFMPs reportées"
        end

        def tooltip_key
          "stats.count.pfmps_report"
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
