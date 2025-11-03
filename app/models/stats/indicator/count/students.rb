# frozen_string_literal: true

module Stats
  module Indicator
    module Count
      class Students < Stats::Count
        def initialize(start_year)
          super(
            all: Student.for_year(start_year).all
          )
        end

        def key
          :students_count
        end

        def title
          "Nb. élèves"
        end

        def tooltip_key
          "stats.count.students"
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
