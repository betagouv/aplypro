# frozen_string_literal: true

module Reports
  class BaseExtractor
    class DataAlreadyLoadedError < StandardError; end

    def initialize(report)
      @report = report
      validate_report_not_loaded!
      @cache = {}
    end

    def extract(*keys)
      keys_to_fetch = keys.reject { |key| @cache.key?(key) }
      fetch_from_database(keys_to_fetch) if keys_to_fetch.any?

      keys.size == 1 ? @cache[keys.first] : @cache.slice(*keys)
    end

    def calculate_stats
      data_row = extract_data_row
      return {} if data_row.nil?

      establishments_count = count_establishments
      build_aggregated_stats(data_row, establishments_count)
    end

    private

    def validate_report_not_loaded!
      return unless @report.has_attribute?(:data)

      raise DataAlreadyLoadedError, "Report was loaded with data column"
    end

    def fetch_from_database(keys)
      select_clauses = keys.map { |key| "data -> '#{key}' as #{key}" }.join(", ")
      result = @report.class.select(select_clauses).find(@report.id)
      keys.each { |key| @cache[key] = result.public_send(key) }
    end

    def extract_data_row
      raise NotImplementedError, "Subclasses must implement extract_data_row"
    end

    def count_establishments
      raise NotImplementedError, "Subclasses must implement count_establishments"
    end

    def indicator_indices
      raise NotImplementedError, "Subclasses must implement indicator_indices"
    end

    def build_aggregated_stats(data_row, establishments_count)
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
