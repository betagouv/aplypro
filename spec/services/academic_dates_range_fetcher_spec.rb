# frozen_string_literal: true

require "rails_helper"

describe AcademicDatesRangeFetcher do
  describe ".call" do
    context "when academy code has no special exception" do
      it "returns a default September 1st range" do
        result = described_class.call("01", 2024)

        expect(result.begin).to eq Date.new(2024, 9, 1)
        expect(result.end).to eq Date.new(2025, 9, 1)
      end
    end

    context "when academy code is Mayotte" do
      it "returns an August 23rd range" do
        result = described_class.call("43", 2024)

        expect(result.begin).to eq Date.new(2024, 8, 23)
        expect(result.end).to eq Date.new(2025, 8, 23)
      end
    end

    context "when academy code is La Réunion" do
      it "returns an August 16th range" do
        result = described_class.call("28", 2024)

        expect(result.begin).to eq Date.new(2024, 8, 16)
        expect(result.end).to eq Date.new(2025, 8, 16)
      end
    end
  end
end
