# frozen_string_literal: true

module Reports
  class StatsExtractor < BaseStatsExtractor
    def self.extract_global_stats(report)
      new(report).extract_stats
    end

    def extract_global_stats
      extract_stats
    end

    private

    def extract_data_row
      global_data = @report.data["global_data"]
      return nil if global_data.blank? || global_data.length < 2

      global_data[1]
    end

    def count_establishments
      establishments_data = @report.data["establishments_data"]
      establishments_data&.length.to_i - 1
    end

    def indicator_indices
      {
        students: 3,
        pfmps: 7,
        validated_pfmps_ratio: 2,
        validated_amount: 4,
        paid_amount: 11
      }
    end
  end
end
