# frozen_string_literal: true

module Reports
  class DataExtractor
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
  end
end
