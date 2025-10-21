# frozen_string_literal: true

module Reports
  class StatsExtractor
    def self.extract_global_stats(report)
      new(report).extract_global_stats
    end

    def initialize(report)
      @report = report
    end

    def extract_global_stats
      global_data = @report.data["global_data"]
      return {} if global_data.blank? || global_data.length < 2

      build_stats_hash(global_data[1], total_establishments_count)
    end

    private

    def total_establishments_count
      establishments_data = @report.data["establishments_data"]
      establishments_data&.length.to_i - 1
    end

    def build_stats_hash(data_row, establishments_count)
      {
        total_establishments: establishments_count,
        total_students: data_row[6].to_i,
        total_pfmps: data_row[7].to_i,
        validated_pfmps: (data_row[2].to_f * data_row[7].to_i).round,
        total_validated_amount: data_row[5].to_f,
        total_paid_amount: data_row[11].to_f
      }
    end
  end
end
