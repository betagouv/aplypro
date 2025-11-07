# frozen_string_literal: true

module Academic
  class ReportsProgressionComparator < Reports::ProgressionComparator
    def self.compare(current_report, previous_report, academy_code)
      new(current_report, previous_report, academy_code).compare
    end

    def initialize(current_report, previous_report, academy_code)
      @academy_code = academy_code
      super(current_report, previous_report)
    end

    private

    def extract_stats(report)
      StatsExtractor.new(report, @academy_code).calculate_stats
    end
  end
end
