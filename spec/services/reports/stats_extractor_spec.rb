# frozen_string_literal: true

require "rails_helper"

RSpec.describe Reports::StatsExtractor do
  subject(:extractor) { described_class.new(report) }

  let!(:full_report) { create(:report) }
  let(:report) { Report.select(:id, :school_year_id, :created_at).find(full_report.id) }

  describe ".extract_global_stats" do
    it "delegates to instance method" do
      expect_any_instance_of(described_class).to receive(:extract_stats) # rubocop:disable RSpec/AnyInstance
      described_class.extract_global_stats(report)
    end
  end

  describe "#extract_global_stats" do
    context "when report has valid global data" do
      let!(:full_report) do
        data_row = Array.new(Report::HEADERS.length, 0)
        data_row[Report::HEADERS.index(:schoolings_count)] = 1500
        data_row[Report::HEADERS.index(:pfmps_count)] = 1000
        data_row[Report::HEADERS.index(:pfmps_validated_count)] = 850
        data_row[Report::HEADERS.index(:pfmps_validated_sum)] = 120_000
        data_row[Report::HEADERS.index(:payment_requests_paid_sum)] = 100_000

        create(:report, data: {
                 "global_data" => [
                   Report::HEADERS,
                   data_row
                 ],
                 "establishments_data" => [
                   %i[uai establishment_name ministry academy private_or_public] + Report::HEADERS,
                   ["Row1"],
                   ["Row2"]
                 ]
               })
      end
      let(:report) { Report.select(:id, :school_year_id, :created_at).find(full_report.id) }

      it "returns stats hash" do
        result = extractor.extract_global_stats

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

    context "when global_data is blank" do
      let!(:full_report) { create(:report, data: { "global_data" => [] }) }
      let(:report) { Report.select(:id, :school_year_id, :created_at).find(full_report.id) }

      it "returns empty hash" do
        expect(extractor.extract_global_stats).to eq({})
      end
    end

    context "when global_data has only headers" do
      let!(:full_report) { create(:report, data: { "global_data" => [["Headers"]] }) }
      let(:report) { Report.select(:id, :school_year_id, :created_at).find(full_report.id) }

      it "returns empty hash" do
        expect(extractor.extract_global_stats).to eq({})
      end
    end

    context "when establishments_data is nil" do
      let!(:full_report) do
        data_row = Array.new(Report::HEADERS.length, 0)
        data_row[Report::HEADERS.index(:schoolings_count)] = 1500
        data_row[Report::HEADERS.index(:pfmps_count)] = 1000
        data_row[Report::HEADERS.index(:pfmps_validated_count)] = 850
        data_row[Report::HEADERS.index(:pfmps_validated_sum)] = 120_000
        data_row[Report::HEADERS.index(:payment_requests_paid_sum)] = 100_000

        create(:report, data: {
                 "global_data" => [
                   Report::HEADERS,
                   data_row
                 ],
                 "establishments_data" => nil
               })
      end
      let(:report) { Report.select(:id, :school_year_id, :created_at).find(full_report.id) }

      it "counts establishments as 0" do
        result = extractor.extract_global_stats
        expect(result[:total_establishments]).to eq(-1)
      end
    end
  end
end
