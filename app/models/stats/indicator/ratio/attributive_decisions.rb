# frozen_string_literal: true

module Stats
  module Indicator
    module Ratio
      class AttributiveDecisions < Stats::Ratio
        def initialize(attributive_decisions_indicator:, schoolings_indicator:)
          super(
            numerator_indicator: attributive_decisions_indicator,
            denominator_indicator: schoolings_indicator
          )
        end

        def self.dependencies
          {
            attributive_decisions_indicator: :attributive_decisions_count,
            schoolings_indicator: :schoolings_count
          }
        end

        def self.key
          :attributive_decisions_ratio
        end

        def self.title
          "Part DA"
        end

        def self.tooltip_key
          "stats.ratio.attributive_decisions"
        end

        def with_mef_and_establishment
          Schooling.joins(classe: %i[mef establishment])
        end

        def with_establishment
          Schooling.joins(classe: :establishment)
        end
      end
    end
  end
end
