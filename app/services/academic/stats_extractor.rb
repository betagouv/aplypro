# frozen_string_literal: true

module Academic
  class StatsExtractor < Reports::BaseStatsExtractor
    def initialize(report, academy_code)
      super(report)
      @academy_code = academy_code
    end

    def extract_stats_from_report(_report = @report)
      extract_stats
    end

    private

    def extract_data_row
      menj_data = @report.data["menj_academies_data"]
      return nil if menj_data.blank?

      academy_label = academy_label_for_code
      menj_data[1..].find { |row| row[0] == academy_label }
    end

    def count_establishments
      establishments_data = @report.data["establishments_data"]
      return 0 if establishments_data.blank?

      establishments_data[1..].count { |row| row[3] == academy_label_for_code }
    end

    def indicator_indices
      {
        students: 7,
        pfmps: 8,
        validated_pfmps_ratio: 3,
        validated_amount: 5,
        paid_amount: 12
      }
    end

    def academy_label_for_code
      Establishment::ACADEMY_LABELS[@academy_code]
    end
  end
end
