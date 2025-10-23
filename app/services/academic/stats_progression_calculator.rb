# frozen_string_literal: true

module Academic
  class StatsProgressionCalculator
    def initialize(report, academy_code)
      @report = report
      @academy_code = academy_code
    end

    def extract_stats_from_report(report = @report)
      academy_row = find_academy_row(report)
      return {} if academy_row.nil?

      build_stats_from_row(academy_row, report)
    end

    private

    def find_academy_row(report)
      menj_data = report.data["menj_academies_data"]
      return nil if menj_data.blank?

      academy_label = academy_label_for_code
      menj_data[1..].find { |row| row[0] == academy_label }
    end

    def build_stats_from_row(academy_row, report)
      establishments_count = count_academy_establishments(report.data["establishments_data"])

      {
        total_establishments: establishments_count,
        total_students: academy_row[4].to_i,
        total_pfmps: academy_row[8].to_i,
        validated_pfmps: calculate_validated_pfmps(academy_row),
        total_validated_amount: academy_row[5].to_f,
        total_paid_amount: academy_row[12].to_f
      }
    end

    def calculate_validated_pfmps(academy_row)
      (academy_row[3].to_f * academy_row[8].to_i).round
    end

    def academy_label_for_code
      Establishment::ACADEMY_LABELS[@academy_code]
    end

    def count_academy_establishments(establishments_data)
      return 0 if establishments_data.blank?

      establishments_data[1..].count { |row| row[3] == academy_label_for_code }
    end
  end
end
