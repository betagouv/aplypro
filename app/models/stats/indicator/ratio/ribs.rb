# frozen_string_literal: true

module Stats
  module Indicator
    module Ratio
      class Ribs < Stats::Ratio
        def initialize(ribs_indicator:, students_indicator:)
          super(
            numerator_indicator: ribs_indicator,
            denominator_indicator: students_indicator
          )
        end

        def self.dependencies
          {
            ribs_indicator: :ribs_count,
            students_indicator: :students_count
          }
        end

        def self.key
          :ribs_ratio
        end

        def self.title
          "Part coord. bancaires"
        end

        def self.tooltip_key
          "stats.ratio.ribs"
        end

        def with_mef_and_establishment
          Student.joins(schoolings: { classe: %i[mef establishment] })
        end

        def with_establishment
          Student.joins(schoolings: { classe: :establishment })
        end
      end
    end
  end
end
