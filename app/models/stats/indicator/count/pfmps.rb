# frozen_string_literal: true

module Stats
  module Indicator
    module Count
      class Pfmps < Stats::Count
        def initialize(start_year)
          super(
            all: Pfmp.for_year(start_year)
          )
        end

        def self.key
          :pfmps_count
        end

        def self.title
          "Toutes PFMPs"
        end

        def self.tooltip_key
          "stats.count.pfmps"
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
