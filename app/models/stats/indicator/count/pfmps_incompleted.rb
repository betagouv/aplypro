# frozen_string_literal: true

module Stats
  module Indicator
    module Count
      class PfmpsIncompleted < Stats::Count
        def initialize(start_year)
          pfmps = Pfmp.for_year(start_year)

          # TODO
          super(
            all: pfmps.in_state(:completed)
          )
        end

        def title
          "Nb. PFMPs incomplètes"
        end

        def tooltip_key
          "stats.count.pfmps_incompleted"
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
