# frozen_string_literal: true

module Stats
  module Indicator
    class Pfmps < Count
      def initialize(start_year)
        super(
          all: Pfmp.for_year(start_year)
        )
      end

      def title
        "Toutes PFMPs"
      end

      def tooltip_key
        "stats.pfmps"
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
