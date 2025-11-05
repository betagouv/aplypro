# frozen_string_literal: true

require "rails_helper"

RSpec.describe Academic::StatsExtractor do
  subject(:extractor) { described_class.new(report, academy_code) }

  let(:academy_code) { "10" }
  let(:report) { create(:report) }

  describe "#extract_stats_from_report" do
    context "when report has valid academy data" do
      let(:report) do
        data_row = Array.new(Report::HEADERS.length, 0)
        data_row[Report::HEADERS.index(:schoolings_count)] = 1500
        data_row[Report::HEADERS.index(:pfmps_count)] = 1000
        data_row[Report::HEADERS.index(:pfmps_validated_count)] = 850
        data_row[Report::HEADERS.index(:pfmps_validated_sum)] = 120_000
        data_row[Report::HEADERS.index(:payment_requests_paid_sum)] = 100_000

        create(:report, data: {
                 "menj_academies_data" => [
                   [:Académie] + Report::HEADERS,
                   ["Lyon"] + data_row
                 ],
                 "establishments_data" => [
                   %i[uai establishment_name ministry academy private_or_public] + Report::HEADERS,
                   ["0010001A", "Lycée 1", "MENJ", "Lyon", "Public"],
                   ["0010002B", "Lycée 2", "MENJ", "Lyon", "Public"]
                 ]
               })
      end

      it "returns stats hash for the academy" do
        result = extractor.extract_stats_from_report

        expect(result).to include(
          total_establishments: 2,
          total_students: 1500,
          total_pfmps: 1000,
          validated_pfmps: 850,
          total_validated_amount: 120_000.0,
          total_paid_amount: 100_000.0
        )
      end
    end

    context "when academy is not found in data" do
      let(:report) do
        create(:report, data: {
                 "menj_academies_data" => [
                   %w[Académie Stats],
                   ["Paris", 100]
                 ]
               })
      end

      it "returns empty hash" do
        expect(extractor.extract_stats_from_report).to eq({})
      end
    end

    context "when menj_academies_data is blank" do
      let(:report) { create(:report, data: { "menj_academies_data" => nil }) }

      it "returns empty hash" do
        expect(extractor.extract_stats_from_report).to eq({})
      end
    end

    context "when establishments_data is blank" do
      let(:report) do
        data_row = Array.new(Report::HEADERS.length, 0)
        data_row[Report::HEADERS.index(:schoolings_count)] = 1500
        data_row[Report::HEADERS.index(:pfmps_count)] = 1000
        data_row[Report::HEADERS.index(:pfmps_validated_count)] = 850
        data_row[Report::HEADERS.index(:pfmps_validated_sum)] = 120_000
        data_row[Report::HEADERS.index(:payment_requests_paid_sum)] = 100_000

        create(:report, data: {
                 "menj_academies_data" => [
                   [:Académie] + Report::HEADERS,
                   ["Lyon"] + data_row
                 ],
                 "establishments_data" => nil
               })
      end

      it "counts establishments as 0" do
        result = extractor.extract_stats_from_report
        expect(result[:total_establishments]).to eq(0)
      end
    end
  end
end
