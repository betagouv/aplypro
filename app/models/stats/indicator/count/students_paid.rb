# frozen_string_literal: true

module Stats
  module Indicator
    module Count
      class StudentsPaid < Stats::Count
        def initialize(start_year)
          # TODO
          super(
            all: Student.for_year(start_year).all
          )
        end

        def title
          "Nb. élèves payés"
        end

        def tooltip_key
          "stats.count.students_paid"
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
