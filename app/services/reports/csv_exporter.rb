# frozen_string_literal: true

module Reports
  class CsvExporter
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
      case cell
      when Float
        number_string(cell)
      when nil
        number_string(nil)
      else
        cell.to_s
      end
    end

    def number_string(ratio)
      return "0" if ratio.nil? || ratio.nan?
      return "Infini" if ratio.infinite?

      ratio.to_s.gsub(".", ",")
    end
  end
end
