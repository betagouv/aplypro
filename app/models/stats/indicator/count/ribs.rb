# frozen_string_literal: true

module Stats
  module Indicator
    module Count
      class Ribs < Stats::Count
        def initialize(start_year)
          students = Student.for_year(start_year)
          super(
            all: students.with_rib
          )
        end

        def key
          :ribs_count
        end

        def title
          "Nb. coord. bancaires"
        end

        def tooltip_key
          "stats.count.ribs"
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
