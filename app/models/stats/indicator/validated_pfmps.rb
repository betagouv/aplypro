# frozen_string_literal: true

module Stats
  module Indicator
    class ValidatedPfmps < Ratio
      def initialize(start_year)
        finished_pfmps = Pfmp.for_year(start_year).finished

        super(
          subset: finished_pfmps.in_state(:validated),
          all: finished_pfmps
        )
      end

      def title
        "PFMPs terminées et validées"
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
