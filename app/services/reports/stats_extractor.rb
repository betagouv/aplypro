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
        students: Report::HEADERS.index("Scolarités"),
        pfmps: Report::HEADERS.index("Toutes PFMPs"),
        validated_pfmps_ratio: Report::HEADERS.index("PFMPs validées"),
        validated_amount: Report::HEADERS.index("Mt. prêt envoi"),
        paid_amount: Report::HEADERS.index("Mt. payé")
      }
    end
  end
end
