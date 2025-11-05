# frozen_string_literal: true

module Stats
  module Indicator
    module Ratio
      class Ribs < Stats::Ratio
        def initialize(start_year)
          students = Student.for_year(start_year)
          super(
            subset: students.with_rib,
            all: students.all
          )
        end

        def key
          :ribs_ratio
        end

        def title
          "Part coord. bancaires"
        end

        def tooltip_key
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
