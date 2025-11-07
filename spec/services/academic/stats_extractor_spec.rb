# frozen_string_literal: true

require "rails_helper"

RSpec.describe Academic::StatsExtractor do
  subject(:extractor) { described_class.new(report, academy_code) }

  let(:academy_code) { "10" }
  let!(:full_report) { create(:report) }
  let(:report) { Report.select(:id, :school_year_id, :created_at).find(full_report.id) }

  describe "#calculate_stats" do
    context "when report has valid academy data" do
      let!(:full_report) do
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
      let(:report) { Report.select(:id, :school_year_id, :created_at).find(full_report.id) }

      it "returns stats hash for the academy" do
        result = extractor.calculate_stats

        expect(result).to include(
          total_students: 1500,
          total_pfmps: 1000,
          validated_pfmps: 850,
          total_validated_amount: 120_000.0,
          total_paid_amount: 100_000.0
        )
      end
    end

    context "when academy is not found in data" do
      let!(:full_report) do
        create(:report, data: {
                 "menj_academies_data" => [
                   %w[Académie Stats],
                   ["Paris", 100]
                 ]
               })
      end
      let(:report) { Report.select(:id, :school_year_id, :created_at).find(full_report.id) }

      it "returns empty hash" do
        expect(extractor.calculate_stats).to eq({})
      end
    end

    context "when menj_academies_data is blank" do
      let!(:full_report) { create(:report, data: { "menj_academies_data" => nil }) }
      let(:report) { Report.select(:id, :school_year_id, :created_at).find(full_report.id) }

      it "returns empty hash" do
        expect(extractor.calculate_stats).to eq({})
      end
    end
  end
end
