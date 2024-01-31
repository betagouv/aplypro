# frozen_string_literal: true

module Stats
  module Indicator
    class YearlyAmounts < Sum
      def initialize
        super(
          column: :yearly_cap,
          all: Schooling.joins(classe: :mef)
                        .merge(Mef.with_wages)
        )
      end

      def title
        "Somme des montants annuels"
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
