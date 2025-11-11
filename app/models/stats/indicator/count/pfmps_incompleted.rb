# frozen_string_literal: true

module Stats
  module Indicator
    module Count
      class PfmpsIncompleted < Stats::Count
        def initialize(start_year)
          pfmps = Pfmp.for_year(start_year)

          pending_or_null = pfmps
                            .left_outer_joins(:transitions)
                            .where(
                              "(pfmp_transitions.to_state = 'pending' AND " \
                              "pfmp_transitions.most_recent = true) OR " \
                              "pfmp_transitions.to_state IS NULL"
                            )
                            .distinct

          super(
            all: pending_or_null
          )
        end

        def self.key
          :pfmps_incompleted_count
        end

        def self.title
          "Nb. PFMPs incomplètes"
        end

        def self.tooltip_key
          "stats.count.pfmps_incompleted"
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
