# frozen_string_literal: true

module Stats
  module Indicator
    class SendableAmounts < Sum
      def initialize(start_year)
        super(
          column: :amount,
          all: Pfmp.for_year(start_year).in_state(:validated).finished.distinct
                   .joins(schooling: { student: :ribs })
                   .merge(Schooling.with_attributive_decisions)
                   .merge(Student.asp_ready)
        )
      end

      def title
        "Somme des PFMPs terminées validées avec RIB, DA & données élèves (prêtes à l'envoi)"
      end

      def with_mef_and_establishment
        Pfmp.joins(schooling: { classe: %i[mef establishment] })
      end

      def with_establishment
        Pfmp.joins(schooling: { classe: :establishment })
      end

      def global_data
        all.to_a.map { |e| e.send(column) }.sum
      end
    end
  end
end
