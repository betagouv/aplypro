# frozen_string_literal: true

module Reports
  class BaseStatsExtractor
    def initialize(report)
      @report = report
      @data_extractor = Reports::DataExtractor.new(report)
    end

    def extract_stats
      data_row = extract_data_row
      return {} if data_row.nil?

      establishments_count = count_establishments
      build_stats_hash(data_row, establishments_count)
    end

    private

    attr_reader :data_extractor

    def extract_data_row
      raise NotImplementedError, "Subclasses must implement extract_data_row"
    end

    def count_establishments
      raise NotImplementedError, "Subclasses must implement count_establishments"
    end

    def indicator_indices
      raise NotImplementedError, "Subclasses must implement indicator_indices"
    end

    def build_stats_hash(data_row, establishments_count)
      indices = indicator_indices

      {
        total_establishments: establishments_count,
        total_students: data_row[indices[:students]].to_i,
        total_pfmps: data_row[indices[:pfmps]].to_i,
        validated_pfmps: data_row[indices[:validated_pfmps_count]].to_i,
        total_validated_amount: data_row[indices[:validated_amount]].to_f,
        total_paid_amount: data_row[indices[:paid_amount]].to_f
      }
    end
  end
end
