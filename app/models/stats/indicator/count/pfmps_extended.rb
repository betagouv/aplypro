# frozen_string_literal: true

module Stats
  module Indicator
    module Count
      class PfmpsExtended < Stats::Count
        def initialize(start_year)
          super(
            all: Pfmp.for_year(start_year)
                 .joins(:schooling)
                 .where.not(schoolings: { extended_end_date: nil })
                 .where("pfmps.end_date > schoolings.end_date")
          )
        end

        def self.key
          :pfmps_extended_count
        end

        def self.title
          "Nb. PFMPs reportées"
        end

        def self.tooltip_key
          "stats.count.pfmps_extended"
        end

        def with_mef_and_establishment
          Pfmp.joins(schooling: { classe: %i[mef establishment school_year] })
        end

        def with_establishment
          Pfmp.joins(schooling: { classe: %i[establishment school_year] })
        end
      end
    end
  end
end
