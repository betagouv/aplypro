# frozen_string_literal: true

module Reports
  class CSVExporter
    attr_reader :report

    def initialize(report)
      @report = report
    end

    def csv_files
      data_extractor = Reports::DataExtractor.new(report)
      extracted_data = data_extractor.extract(:global_data, :bops_data, :menj_academies_data, :establishments_data)
      {
        "statistiques_globales.csv" => convert_to_csv(extracted_data[:global_data]),
        "statistiques_bops.csv" => convert_to_csv(extracted_data[:bops_data]),
        "statistiques_academies_menj.csv" => convert_to_csv(extracted_data[:menj_academies_data]),
        "statistiques_etablissements.csv" => convert_to_csv(extracted_data[:establishments_data])
      }
    end

    private

    def convert_to_csv(data)
      return "" if data.blank?

      data.map { |row| row.map { |cell| format_cell_for_csv(cell) }.join(";") }.join("\n")
    end

    def format_cell_for_csv(cell)
      return "0" if cell.nil?
      return "Infini" if cell.respond_to?(:infinite?) && cell.infinite?
      return "0" if cell.respond_to?(:nan?) && cell.nan?
      return cell.to_s unless valid_numeric?(cell)

      rounded_value = round_value(cell)
      rounded_value.to_s.gsub(".", ",")
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
