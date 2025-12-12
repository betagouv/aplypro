# frozen_string_literal: true

module Reports
  class CSVExporter
    include BaseCSVExporter

    attr_reader :report

    def initialize(report)
      @report = report
    end

    def csv_files
      extractor = Reports::BaseExtractor.new(report)
      extracted_data = extractor.extract(:global_data, :bops_data, :menj_academies_data, :establishments_data)
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
  end
end
