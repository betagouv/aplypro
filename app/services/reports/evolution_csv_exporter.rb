# frozen_string_literal: true

module Reports
  class EvolutionCSVExporter
    include BaseCSVExporter

    attr_reader :school_year, :reports, :evolution_data, :indicators_metadata

    def initialize(school_year)
      @school_year = school_year
      @reports = fetch_reports
      @evolution_data = build_evolution_data
      @indicators_metadata = Stats::Main.indicators_metadata
    end

    def csv_content
      return "" if evolution_data.blank?

      headers = ["Date du rapport", "ID du rapport"] + indicators_metadata.pluck(:title)
      csv_rows = [headers] + data_rows

      csv_rows.map { |row| row.join(";") }.join("\n")
    end

    def filename
      year = school_year.start_year
      date = Time.current.strftime("%Y%m%d")
      "aplypro_evolution_annee-scol#{year}_date#{date}.csv"
    end

    private

    def fetch_reports
      Report.select(:id, :school_year_id, :created_at)
            .where(school_year: school_year)
            .order(created_at: :desc)
    end

    def build_evolution_data
      return [] if reports.empty?

      reports.map do |report|
        extractor = Reports::BaseExtractor.new(report)
        global_data = extractor.extract(:global_data)

        {
          report: report,
          date: report.created_at,
          values: global_data.last
        }
      end
    end

    def data_rows
      evolution_data.map do |data|
        [data[:date].strftime("%d/%m/%Y %H:%M"), data[:report].id.to_s] +
          data[:values].map { |value| format_cell_for_csv(value) }
      end
    end
  end
end
