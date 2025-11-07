# frozen_string_literal: true

module Academic
  class StatsExtractor < Reports::BaseExtractor
    def initialize(report, academy_code)
      super(report)
      @academy_code = academy_code
    end

    private

    def extract_data_row
      menj_data = extract(:menj_academies_data)
      return nil if menj_data.blank?

      academy_label = academy_label_for_code
      menj_data[1..].find { |row| row[0] == academy_label }
    end

    def indicator_indices
      offset = 1 # menj_academies_data has "Académie" prefix column
      {
        students: offset + Report::HEADERS.index(:schoolings_count),
        pfmps: offset + Report::HEADERS.index(:pfmps_count),
        validated_pfmps_count: offset + Report::HEADERS.index(:pfmps_validated_count),
        validated_amount: offset + Report::HEADERS.index(:pfmps_validated_sum),
        paid_amount: offset + Report::HEADERS.index(:payment_requests_paid_sum)
      }
    end

    def academy_label_for_code
      Establishment::ACADEMY_LABELS[@academy_code]
    end
  end
end
