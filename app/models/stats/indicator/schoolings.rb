# frozen_string_literal: true

module Stats
  module Indicator
    class Schoolings < Count
      def initialize(start_year)
        super(
          all: Schooling.for_year(start_year).all
        )
      end

      def title
        "Scolarités"
      end

      def tooltip_key
        "stats.schoolings"
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
