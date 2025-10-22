# frozen_string_literal: true

module Reports
  class GlobalProgressionComparator < ProgressionComparator
    private

    def extract_stats(report)
      global_data = report.data["global_data"]
      return {} if global_data.blank? || global_data.length < 2

      build_stats_hash(global_data[1], total_establishments_count(report))
    end

    def total_establishments_count(report)
      establishments_data = report.data["establishments_data"]
      establishments_data&.length.to_i - 1
    end

    def build_stats_hash(data_row, establishments_count)
      {
        total_establishments: establishments_count,
        total_students: data_row[3].to_i,
        total_pfmps: data_row[7].to_i,
        validated_pfmps: (data_row[2].to_f * data_row[7].to_i).round,
        total_validated_amount: data_row[4].to_f,
        total_paid_amount: data_row[11].to_f
      }
    end
  end
end
