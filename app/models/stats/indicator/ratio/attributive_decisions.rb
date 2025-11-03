# frozen_string_literal: true

module Stats
  module Indicator
    module Ratio
      class AttributiveDecisions < Stats::Ratio
        def initialize(start_year)
          schoolings = Schooling.for_year(start_year)
          super(
            subset: schoolings.with_attributive_decisions,
            all: schoolings.all
          )
        end

        def key
          :attributive_decisions_ratio
        end

        def title
          "Part DA"
        end

        def tooltip_key
          "stats.ratio.attributive_decisions"
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
