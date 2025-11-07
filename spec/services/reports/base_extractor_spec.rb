# frozen_string_literal: true

require "rails_helper"

RSpec.describe Reports::BaseExtractor do
  subject(:extractor) { described_class.new(report) }

  let(:school_year) { SchoolYear.find_or_create_by(start_year: 2024) }
  let!(:full_report) do
    create(:report, school_year: school_year, data: {
             "global_data" => [
               %w[Header1 Header2],
               [123, 456]
             ],
             "bops_data" => [
               %w[BOP Value],
               ["ENPU", 100]
             ],
             "menj_academies_data" => [
               %w[Académie Value],
               ["Paris", 200]
             ],
             "establishments_data" => [
               %w[UAI Value],
               ["0750001A", 85]
             ]
           })
  end

  describe "#extract" do
    context "when report is loaded without data column" do
      let(:report) { Report.select(:id, :school_year_id, :created_at).find(full_report.id) }

      it "does not raise MissingAttributeError" do
        expect { extractor.extract(:global_data) }.not_to raise_error
      end

      it "extracts data correctly using JSONB operators" do
        result = extractor.extract(:global_data)
        expect(result).to eq([%w[Header1 Header2], [123, 456]])
      end

      it "extracts multiple keys at once" do
        result = extractor.extract(:global_data, :bops_data)
        expect(result[:global_data]).to eq([%w[Header1 Header2], [123, 456]])
        expect(result[:bops_data]).to eq([%w[BOP Value], ["ENPU", 100]])
      end

      it "caches extracted data to avoid duplicate queries" do
        first_result = extractor.extract(:global_data)
        second_result = extractor.extract(:global_data)

        expect(first_result).to eq(second_result)
        expect(second_result).to eq([%w[Header1 Header2], [123, 456]])
      end

      it "makes only one query when extracting multiple keys together" do
        query_count = 0
        callback = lambda do |_name, _started, _finished, _unique_id, payload|
          query_count += 1 if payload[:sql].match?(/SELECT.*data ->/)
        end

        ActiveSupport::Notifications.subscribed(callback, "sql.active_record") do
          extractor.extract(:global_data, :bops_data, :menj_academies_data)
        end

        expect(query_count).to eq(1)
      end
    end

    context "when report is loaded with data column" do
      let(:report) { Report.find(full_report.id) }

      it "raises DataAlreadyLoadedError" do
        expect { extractor }.to raise_error(
          Reports::BaseExtractor::DataAlreadyLoadedError,
          /Report was loaded with data column/
        )
      end
    end

    context "when extracting single key" do
      let(:report) { Report.select(:id, :school_year_id, :created_at).find(full_report.id) }

      it "returns the value directly, not a hash" do
        result = extractor.extract(:global_data)
        expect(result).to eq([%w[Header1 Header2], [123, 456]])
        expect(result).not_to be_a(Hash)
      end
    end

    context "when extracting multiple keys" do
      let(:report) { Report.select(:id, :school_year_id, :created_at).find(full_report.id) }

      it "returns a hash with keys as symbols" do
        result = extractor.extract(:global_data, :bops_data)
        expect(result).to be_a(Hash)
        expect(result.keys).to contain_exactly(:global_data, :bops_data)
      end
    end
  end
end
