# frozen_string_literal: true

module Stats
  module Indicator
    class Payments < Sum
      def initialize
        super(
          column: :amount,
          all: Pfmp.joins(schooling: { student: :rib })
                   .merge(Pfmp.finished)
                   .merge(Pfmp.in_state(:validated))
                   .merge(Schooling.with_attributive_decisions)
                   .merge(Student.asp_ready)
        )
      end

      def title
        "Somme des PFMPs terminées validées avec RIB, DA & données élèves"
      end

      def with_mef_and_establishment
        Pfmp.joins(schooling: { classe: %i[mef establishment] })
      end

      def with_establishment
        Pfmp.joins(schooling: { classe: :establishment })
      end
    end
  end
end
