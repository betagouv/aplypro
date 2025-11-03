# frozen_string_literal: true

module Stats
  module Indicator
    module Count
      class PfmpsGhost < Stats::Count
        def initialize(start_year)
          finished_pfmps = Pfmp.for_year(start_year).finished

          # TODO
          super(
            all: finished_pfmps.in_state(:validated)
          )
        end

        def title
          "Nb PFMPs fantômes"
        end

        def tooltip_key
          "stats.count.pfmps_ghost"
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
