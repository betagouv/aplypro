# frozen_string_literal: true

module Stats
  module Indicator
    module Count
      class Schoolings < Stats::Count
        def initialize(start_year)
          super(
            all: Schooling.for_year(start_year).all
          )
        end

        def key
          :schoolings_count
        end

        def title
          "Nb. scolarités"
        end

        def tooltip_key
          "stats.count.schoolings"
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
