# frozen_string_literal: true

module Stats
  module Indicator
    module Ratio
      class PfmpsValidated < Stats::Ratio
        def initialize(validated_indicator:, pfmps_indicator:)
          super(
            numerator_indicator: validated_indicator,
            denominator_indicator: pfmps_indicator
          )
        end

        def self.dependencies
          {
            validated_indicator: :pfmps_validated_count,
            pfmps_indicator: :pfmps_count
          }
        end

        def self.key
          :pfmps_validated_ratio
        end

        def self.title
          "Part PFMPs validées"
        end

        def self.tooltip_key
          "stats.ratio.pfmps_validated"
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
