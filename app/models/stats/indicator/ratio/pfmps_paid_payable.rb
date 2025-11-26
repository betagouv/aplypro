# frozen_string_literal: true

module Stats
  module Indicator
    module Ratio
      class PfmpsPaidPayable < Stats::Ratio
        def initialize(paid_indicator:, payable_indicator:)
          super(
            numerator_indicator: paid_indicator,
            denominator_indicator: payable_indicator
          )
        end

        def self.dependencies
          {
            paid_indicator: :pfmps_paid_count,
            payable_indicator: :pfmps_payable_count
          }
        end

        def self.key
          :pfmps_paid_payable_ratio
        end

        def self.title
          "Part PFMPs payées/payables"
        end

        def self.tooltip_key
          "stats.ratio.pfmps_paid_payable"
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
