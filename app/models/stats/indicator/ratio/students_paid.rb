# frozen_string_literal: true

module Stats
  module Indicator
    module Ratio
      class StudentsPaid < Stats::Ratio
        def initialize(students_paid_indicator:, students_indicator:)
          super(
            numerator_indicator: students_paid_indicator,
            denominator_indicator: students_indicator
          )
        end

        def self.dependencies
          {
            students_paid_indicator: :students_paid_count,
            students_indicator: :students_count
          }
        end

        def self.key
          :students_paid_ratio
        end

        def self.title
          "Part élèves payés"
        end

        def self.tooltip_key
          "stats.ratio.students_paid"
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
