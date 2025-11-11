# frozen_string_literal: true

module Stats
  module Indicator
    module Count
      class AttributiveDecisions < Stats::Count
        def initialize(start_year)
          schoolings = Schooling.for_year(start_year)
          super(
            all: schoolings.with_attributive_decisions
          )
        end

        def self.key
          :attributive_decisions_count
        end

        def self.title
          "Nb. DA"
        end

        def self.tooltip_key
          "stats.count.attributive_decisions"
        end

        def with_mef_and_establishment
          Schooling.joins(classe: %i[mef establishment school_year])
        end

        def with_establishment
          Schooling.joins(classe: %i[establishment school_year])
        end
      end
    end
  end
end
