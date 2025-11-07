# frozen_string_literal: true

module Reports
  class StatsExtractor < BaseExtractor
    private

    def extract_data_row
      global_data = extract(:global_data)
      return nil if global_data.blank? || global_data.length < 2

      global_data[1]
    end

    def indicator_indices
      {
        students: Report::HEADERS.index(:schoolings_count),
        pfmps: Report::HEADERS.index(:pfmps_count),
        validated_pfmps_count: Report::HEADERS.index(:pfmps_validated_count),
        validated_amount: Report::HEADERS.index(:pfmps_validated_sum),
        paid_amount: Report::HEADERS.index(:payment_requests_paid_sum)
      }
    end
  end
end
