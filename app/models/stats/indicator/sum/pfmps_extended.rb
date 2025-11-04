# frozen_string_literal: true

module Stats
  module Indicator
    module Sum
      class PfmpsExtended < Stats::Sum
        def initialize(start_year)
          super(
            column: :amount,
            all: Pfmp.for_year(start_year)
                     .joins(:schooling)
                     .where.not(schoolings: { end_date: nil })
                     .where("pfmps.end_date > schoolings.end_date")
          )
        end

        def key
          :pfmps_extended_sum
        end

        def title
          "Mt. PFMPs reportées"
        end

        def tooltip_key
          "stats.sum.pfmps_extended"
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
