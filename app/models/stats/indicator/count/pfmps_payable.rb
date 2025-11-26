# frozen_string_literal: true

module Stats
  module Indicator
    module Count
      class PfmpsPayable < Stats::Count
        def initialize(start_year)
          payable_base = Pfmp.for_year(start_year).finished.distinct
                             .in_state(:validated, :rectified)
                             .joins(:schooling)
                             .merge(Schooling.with_attributive_decisions)
                             .where(schoolings: { status: 0 })

          super(
            all: payable_base
          )
        end

        def self.key
          :pfmps_payable_count
        end

        def self.title
          "Nb. PFMPs payables"
        end

        def self.tooltip_key
          "stats.count.pfmps_payable"
        end

        def with_mef_and_establishment
          Pfmp.joins(schooling: { classe: %i[mef establishment school_year] })
        end

        def with_establishment
          Pfmp.joins(schooling: { classe: %i[establishment school_year] })
        end
      end
    end
  end
end
