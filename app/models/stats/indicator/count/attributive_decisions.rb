# frozen_string_literal: true

module Stats
  module Indicator
    module Count
      class AttributiveDecisions < Stats::Count
        def initialize(start_year)
          schoolings = Schooling.for_year(start_year)
          super(
            all: schoolings.with_attributive_decisions
          )
        end

        def title
          "Nb DA"
        end

        def tooltip_key
          "stats.count.attributive_decisions"
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
