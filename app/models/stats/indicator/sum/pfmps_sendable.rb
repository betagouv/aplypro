# frozen_string_literal: true

module Stats
  module Indicator
    module Sum
      class PfmpsSendable < Stats::Sum
        def initialize(start_year)
          # TODO: ça correspond à quoi ?
          super(
            column: :amount,
            all: Pfmp.for_year(start_year).in_state(:validated).finished.distinct
                     .joins(schooling: { student: :ribs })
                     .merge(Schooling.with_attributive_decisions)
                     .merge(Student.asp_ready)
          )
        end

        def title
          "Mt prêt envoi"
        end

        def tooltip_key
          "stats.sum.pfmps_sendable"
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
end
