# frozen_string_literal: true

module Reports
  class BaseExtractor
    class DataAlreadyLoadedError < StandardError; end

    def initialize(report)
      @report = report
      validate_report_not_loaded!
    end

    def extract(*keys)
      results = {}
      uncached_keys = []

      keys.each do |key|
        cached_value = Rails.cache.read(cache_key(key))
        if cached_value
          results[key] = cached_value
        else
          uncached_keys << key
        end
      end

      results.merge!(fetch_from_database(uncached_keys)) if uncached_keys.any?

      keys.size == 1 ? results[keys.first] : results.slice(*keys)
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
      return {} if keys.empty?

      select_clauses = keys.map { |key| "data -> '#{key}' as #{key}" }.join(", ")
      result = @report.class.select(select_clauses).find(@report.id)

      fetched_data = {}
      keys.each do |key|
        value = result.public_send(key)
        Rails.cache.write(cache_key(key), value, expires_in: 1.week)
        fetched_data[key] = value
      end

      fetched_data
    end

    def cache_key(key)
      "reports/#{@report.id}/#{key}"
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
