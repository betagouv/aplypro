# frozen_string_literal: true

module Stats
  module Indicator
    class Ribs < Ratio
      def initialize(start_year)
        students = Student.for_year(start_year)
        super(
          subset: students.with_rib,
          all: students.all
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
