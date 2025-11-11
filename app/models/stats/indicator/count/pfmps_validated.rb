# frozen_string_literal: true

module Stats
  module Indicator
    module Count
      class PfmpsValidated < Stats::Count
        def initialize(start_year)
          finished_pfmps = Pfmp.for_year(start_year).finished

          super(
            all: finished_pfmps.in_state(:validated, :rectified)
          )
        end

        def self.key
          :pfmps_validated_count
        end

        def self.title
          "Nb. PFMPs validées"
        end

        def self.tooltip_key
          "stats.count.pfmps_validated"
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
