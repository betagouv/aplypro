# frozen_string_literal: true

module Stats
  module Indicator
    class Ribs < Ratio
      def initialize
        super(
          subset: Student.joins(:rib),
          all: Student.all
        )
      end

      def title
        "Coordonnées bancaires saisies"
      end

      def with_mef_and_establishment
        Student.joins(schoolings: { classe: %i[mef establishment] })
      end

      def with_establishment
        Student.joins(schoolings: { classe: :establishment })
      end
    end
  end
end
