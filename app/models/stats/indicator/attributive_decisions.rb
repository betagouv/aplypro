# frozen_string_literal: true

module Stats
  module Indicator
    class AttributiveDecisions < Ratio
      def initialize(start_year)
        schoolings = Schooling.for_year(start_year)
        super(
          subset: schoolings.with_attributive_decisions,
          all: schoolings.all
        )
      end

      def title
        "DA"
      end

      def tooltip_key
        "stats.attributive_decisions"
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
