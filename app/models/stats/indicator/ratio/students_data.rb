# frozen_string_literal: true

module Stats
  module Indicator
    module Ratio
      class StudentsData < Stats::Ratio
        def initialize(students_data_indicator:, students_indicator:)
          super(
            numerator_indicator: students_data_indicator,
            denominator_indicator: students_indicator
          )
        end

        def self.dependencies
          {
            students_data_indicator: :students_data_count,
            students_indicator: :students_count
          }
        end

        def self.key
          :students_data_ratio
        end

        def self.title
          "Part données élèves"
        end

        def self.tooltip_key
          "stats.ratio.students_data"
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
