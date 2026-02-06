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

        def self.key
          :yearly_sum
        end

        def self.title
          "Mt. annuel total"
        end

        def self.tooltip_key
          "stats.sum.yearly"
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
