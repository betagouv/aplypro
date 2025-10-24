# frozen_string_literal: true

require "rails_helper"

RSpec.describe Academic::StatsExtractor do
  subject(:extractor) { described_class.new(report, academy_code) }

  let(:academy_code) { "10" }
  let(:report) { create(:report) }

  describe "#extract_stats_from_report" do
    context "when report has valid academy data" do
      let(:report) do
        create(:report, data: {
                 "menj_academies_data" => [
                   ["Académie", "DA", "RIBs", "PFMPs validées", "Données élèves", "Mt. prêt envoi", "Scolarités", "Élèves", "Toutes PFMPs", "Sent", "Integrated", "Paid", "Mt. payé"], # rubocop:disable Layout/LineLength
                   ["Lyon", 100, 95, 0.85, 1500, 120_000, 50, 1400, 1000, 80, 75, 70, 100_000]
                 ],
                 "establishments_data" => [
                   ["UAI", "Nom", "Ministère", "Lyon", "Public"],
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
        create(:report, data: {
                 "menj_academies_data" => [
                   # rubocop:disable Layout/LineLength
                   ["Académie", "DA", "RIBs", "PFMPs validées", "Données élèves", "Mt. prêt envoi", "Scolarités", "Élèves", "Toutes PFMPs", "Sent", "Integrated", "Paid", "Mt. payé"],
                   # rubocop:enable Layout/LineLength
                   ["Lyon", 100, 95, 0.85, 1500, 120_000, 50, 1400, 1000, 80, 75, 70, 100_000]
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
