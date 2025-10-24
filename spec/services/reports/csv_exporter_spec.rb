# frozen_string_literal: true

require "rails_helper"

RSpec.describe Reports::CSVExporter do
  subject(:exporter) { described_class.new(report) }

  let(:school_year) { SchoolYear.find_or_create_by(start_year: 2024) }
  let(:report) do
    create(:report, school_year: school_year, data: {
             "global_data" => [
               %w[Header1 Header2],
               [123, 45.678]
             ],
             "bops_data" => [
               %w[BOP Value],
               ["ENPU", 100.5]
             ],
             "menj_academies_data" => [
               %w[Académie Value],
               ["Paris", 200.123]
             ],
             "establishments_data" => [
               %w[UAI Value],
               ["0750001A", 0.85]
             ]
           })
  end

  describe "#csv_files" do
    it "returns a hash with 4 CSV files" do
      result = exporter.csv_files

      expect(result.keys).to contain_exactly("statistiques_globales.csv", "statistiques_bops.csv",
                                             "statistiques_academies_menj.csv", "statistiques_etablissements.csv")
    end

    it "generates CSV content with semicolon separator" do
      result = exporter.csv_files

      result.each_value do |csv_content|
        expect(csv_content).to include(";")
      end
    end

    it "converts decimal points to commas" do
      result = exporter.csv_files

      expect(result["statistiques_globales.csv"]).to include("45,68")
    end

    it "rounds floats to 2 decimal places" do
      result = exporter.csv_files

      expect(result["statistiques_bops.csv"]).to include("100,5")
      expect(result["statistiques_academies_menj.csv"]).to include("200,12")
    end

    it "keeps integers as integers" do
      result = exporter.csv_files

      expect(result["statistiques_globales.csv"]).to include("123")
    end

    it "handles ratios correctly" do
      result = exporter.csv_files

      expect(result["statistiques_etablissements.csv"]).to include("0,85")
    end
  end

  describe "special value handling" do
    let(:report) do
      instance_double(Report, data: {
                        "global_data" => [
                          ["Header"],
                          [nil]
                        ],
                        "bops_data" => [
                          %w[BOP Value],
                          ["ENPU", Float::NAN]
                        ],
                        "menj_academies_data" => [
                          %w[Académie Value],
                          ["Paris", Float::INFINITY]
                        ],
                        "establishments_data" => [
                          ["UAI"],
                          ["0750001A"]
                        ]
                      })
    end

    it "converts nil to 0" do
      result = exporter.csv_files
      expect(result["statistiques_globales.csv"]).to include("0")
    end

    it "converts NaN to 0" do
      result = exporter.csv_files
      expect(result["statistiques_bops.csv"]).to include("0")
    end

    it "converts Infinity to 'Infini'" do
      result = exporter.csv_files
      expect(result["statistiques_academies_menj.csv"]).to include("Infini")
    end
  end

  describe "with empty data" do
    let(:report) do
      create(:report, school_year: SchoolYear.find_or_create_by(start_year: 2024), data: {
               "global_data" => nil,
               "bops_data" => [],
               "menj_academies_data" => nil,
               "establishments_data" => []
             })
    end

    it "returns empty strings for blank data" do
      result = exporter.csv_files

      expect(result["statistiques_globales.csv"]).to eq("")
      expect(result["statistiques_bops.csv"]).to eq("")
    end
  end
end
