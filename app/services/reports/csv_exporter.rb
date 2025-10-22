# frozen_string_literal: true

module Reports
  class CSVExporter
    attr_reader :report

    def initialize(report)
      @report = report
    end

    def csv_files
      {
        "statistiques_globales.csv" => convert_to_csv(report.data["global_data"]),
        "statistiques_bops.csv" => convert_to_csv(report.data["bops_data"]),
        "statistiques_academies_menj.csv" => convert_to_csv(report.data["menj_academies_data"]),
        "statistiques_etablissements.csv" => convert_to_csv(report.data["establishments_data"])
      }
    end

    private

    def convert_to_csv(data)
      return "" if data.blank?

      data.map { |row| row.map { |cell| format_cell_for_csv(cell) }.join(";") }.join("\n")
    end

    def format_cell_for_csv(cell)
      return handle_special_values(cell) unless valid_numeric?(cell)

      rounded_value = round_value(cell)
      rounded_value.to_s.gsub(".", ",")
    end

    def handle_special_values(value)
      return "0" if value.nil?
      return "Infini" if value.respond_to?(:infinite?) && value.infinite?
      return "0" if value.respond_to?(:nan?) && value.nan?

      value.to_s
    end

    def valid_numeric?(value)
      value.is_a?(Numeric)
    end

    def round_value(value)
      return value.to_i if integer_value?(value)

      value.round(2)
    end

    def integer_value?(value)
      value.is_a?(Integer) || (value.is_a?(Numeric) && value == value.to_i)
    end
  end
end
