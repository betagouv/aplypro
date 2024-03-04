# frozen_string_literal: true

module Stats
  module Indicator
    class Schoolings < Count
      def initialize
        super(
          all: Schooling.all
        )
      end

      def title
        "Scolarités concernées"
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
