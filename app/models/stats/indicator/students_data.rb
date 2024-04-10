# frozen_string_literal: true

module Stats
  module Indicator
    class StudentsData < Ratio
      def initialize
        super(
          subset: Student.with_biological_sex.with_valid_birthplace,
          all: Student.all
        )
      end

      def title
        "Données d'élèves nécessaires présentes"
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
