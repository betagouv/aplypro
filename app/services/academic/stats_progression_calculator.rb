# frozen_string_literal: true

module Academic
  class StatsProgressionCalculator
    def initialize(current_report, academy_code, current_stats)
      @current_report = current_report
      @academy_code = academy_code
      @current_stats = current_stats
    end

    def calculate
      return {} unless @current_report.previous_report

      previous_stats = extract_stats_from_report(@current_report.previous_report)
      calculate_progressions(previous_stats)
    end

    def extract_stats_from_report(report)
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
        total_students: academy_row[7].to_i,
        total_pfmps: academy_row[8].to_i,
        validated_pfmps: calculate_validated_pfmps(academy_row),
        total_validated_amount: academy_row[6].to_f,
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

    def calculate_progressions(previous_stats)
      progressions = {}
      @current_stats.each do |key, current_value|
        previous_value = previous_stats[key]
        next if previous_value.nil? || previous_value.zero?

        progression = ((current_value.to_f - previous_value.to_f) / previous_value.to_f * 100).round(1)
        progressions[key] = progression unless progression.zero?
      end
      progressions
    end
  end
end
