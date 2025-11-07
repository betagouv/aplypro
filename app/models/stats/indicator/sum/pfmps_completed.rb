# frozen_string_literal: true

module Stats
  module Indicator
    module Sum
      class PfmpsCompleted < Stats::Sum
        def initialize(start_year)
          pfmps = Pfmp.for_year(start_year)

          super(
            column: :amount,
            all: pfmps.in_state(:completed)
          )
        end

        def self.key
          :pfmps_completed_sum
        end

        def self.title
          "Mt. PFMPs complétées"
        end

        def self.tooltip_key
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
