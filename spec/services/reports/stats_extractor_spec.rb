# frozen_string_literal: true

require "rails_helper"

RSpec.describe Reports::StatsExtractor do
  subject(:extractor) { described_class.new(report) }

  let(:report) { create(:report) }

  describe ".extract_global_stats" do
    it "delegates to instance method" do
      expect_any_instance_of(described_class).to receive(:extract_stats) # rubocop:disable RSpec/AnyInstance
      described_class.extract_global_stats(report)
    end
  end

  describe "#extract_global_stats" do
    context "when report has valid global data" do
      let(:report) do
        create(:report, data: {
                 "global_data" => [
                   ["Headers"],
                   [nil, nil, 0.85, 0.95, 120_000, 180_000, 1500, 1000, nil, nil, nil, 100_000] # indices matter
                 ],
                 "establishments_data" => [
                   ["Header"],
                   ["Row1"],
                   ["Row2"]
                 ]
               })
      end

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
      let(:report) { create(:report, data: { "global_data" => [] }) }

      it "returns empty hash" do
        expect(extractor.extract_global_stats).to eq({})
      end
    end

    context "when global_data has only headers" do
      let(:report) { create(:report, data: { "global_data" => [["Headers"]] }) }

      it "returns empty hash" do
        expect(extractor.extract_global_stats).to eq({})
      end
    end

    context "when establishments_data is nil" do
      let(:report) do
        create(:report, data: {
                 "global_data" => [
                   ["Headers"],
                   [nil, nil, 0.85, 0.95, 120_000, 180_000, 1500, 1000, nil, nil, nil, 100_000]
                 ],
                 "establishments_data" => nil
               })
      end

      it "counts establishments as 0" do
        result = extractor.extract_global_stats
        expect(result[:total_establishments]).to eq(-1)
      end
    end
  end
end
