# frozen_string_literal: true

module Reports
  class ProgressionComparator
    class InvalidComparisonError < StandardError; end

    def self.compare(current_report, previous_report)
      new(current_report, previous_report).compare
    end

    def initialize(current_report, previous_report)
      @current_report = current_report
      @previous_report = previous_report
      validate_reports!
    end

    def compare
      current_stats = extract_stats(@current_report)
      previous_stats = extract_stats(@previous_report)

      calculate_progressions(current_stats, previous_stats)
    end

    private

    def validate_reports!
      raise InvalidComparisonError, "Previous report cannot be nil" if @previous_report.nil?

      if @previous_report.created_at >= @current_report.created_at
        raise InvalidComparisonError,
              "Previous report must be older than current report"
      end

      return if @previous_report.school_year_id == @current_report.school_year_id

      raise InvalidComparisonError,
            "Reports must be from the same school year"
    end

    def extract_stats(_report)
      raise NotImplementedError, "Subclasses must implement extract_stats"
    end

    def calculate_progressions(current_stats, previous_stats)
      progressions = {}
      current_stats.each do |key, current_value|
        previous_value = previous_stats[key]
        next if previous_value.nil? || previous_value.zero?

        progression = progression_percentage(current_value, previous_value)
        progressions[key] = progression unless progression.zero?
      end
      progressions
    end

    def progression_percentage(current_value, previous_value)
      ((current_value.to_f - previous_value.to_f) / previous_value.to_f * 100).round(1)
    end
  end
end
