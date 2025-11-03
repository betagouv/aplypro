# frozen_string_literal: true

module Stats
  module Indicator
    module Count
      class StudentsData < Stats::Count
        def initialize(start_year)
          students = Student.for_year(start_year)

          super(
            all: students.asp_ready
          )
        end

        def title
          "Nb. données élèves"
        end

        def tooltip_key
          "stats.count.students_data"
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
