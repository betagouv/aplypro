# frozen_string_literal: true

module Stats
  module Indicator
    class AttributiveDecisions < Ratio
      def initialize
        super(
          subset: Schooling.with_attributive_decisions,
          all: Schooling.all
        )
      end

      def title
        "Décisions d'attributions éditées"
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
