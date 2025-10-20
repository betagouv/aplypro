# frozen_string_literal: true

module Stats
  module Indicator
    module Sum
      class Yearly < Stats::Sum
        def initialize(start_year)
          super(
            column: :yearly_cap,
            all: Schooling.for_year(start_year).joins(classe: :mef)
                          .merge(Mef.with_wages)
          )
        end

        def title
          "Mt. annuel total"
        end

        def tooltip_key
          "stats.yearly_amounts"
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
