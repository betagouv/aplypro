# frozen_string_literal: true

module Stats
  module Indicator
    module Ratio
      class StudentsData < Stats::Ratio
        def initialize(start_year)
          students = Student.for_year(start_year)

          super(
            subset: students.asp_ready,
            all: students.all
          )
        end

        def title
          "Part données élèves"
        end

        def tooltip_key
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
