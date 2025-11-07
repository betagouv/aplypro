# frozen_string_literal: true

module Reports
  class GlobalProgressionComparator < ProgressionComparator
    private

    def extract_stats(report)
      StatsExtractor.new(report).calculate_stats
    end
  end
end
