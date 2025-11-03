# frozen_string_literal: true

module Stats
  module Indicator
    module Sum
      class PfmpsCompleted < Stats::Sum
        def initialize(start_year)
          pfmps = Pfmp.for_year(start_year)

          # TODO: paid_amount
          super(
            all: pfmps.in_state(:completed)
          )
        end

        def title
          "Mt PFMPs complétées"
        end

        def tooltip_key
          "stats.sum.pfmps_completed"
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
