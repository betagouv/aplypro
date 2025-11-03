# frozen_string_literal: true

module Stats
  module Indicator
    module Sum
      class PfmpsValidated < Stats::Sum
        def initialize(start_year)
          finished_pfmps = Pfmp.for_year(start_year).finished

          # TODO: paid_amount
          super(
            subset: finished_pfmps.in_state(:validated),
            all: finished_pfmps
          )
        end

        def title
          "Mt. PFMPs validées"
        end

        def tooltip_key
          "stats.sum.pfmps_validated"
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
