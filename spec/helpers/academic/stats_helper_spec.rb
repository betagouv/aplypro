# frozen_string_literal: true

require "rails_helper"

RSpec.describe Academic::StatsHelper do
  describe "#format_stat_value" do
    context "with nil value" do
      it "returns N/A" do
        expect(helper.format_stat_value(nil)).to eq("N/A")
      end
    end

    context "with non-numeric value" do
      it "returns the string representation" do
        expect(helper.format_stat_value("some text")).to eq("some text")
      end
    end

    context "with currency amounts" do
      it "formats values as currency with Stats::Sum indicator" do
        expect(helper.format_stat_value(1500.50, indicator_type: "Stats::Sum"))
          .to eq("1 500,5 €")
      end

      it "formats small values as currency with Stats::Sum indicator" do
        expect(helper.format_stat_value(150.50, indicator_type: "Stats::Sum"))
          .to eq("150,5 €")
      end

      it "formats integer values as currency with Stats::Sum indicator" do
        expect(helper.format_stat_value(500, indicator_type: "Stats::Sum"))
          .to eq("500 €")
      end

      it "does not format decimal values without indicator type" do
        expect(helper.format_stat_value(2000.75)).to eq("2 000,75")
      end

      it "does not format integer values without indicator type" do
        expect(helper.format_stat_value(500)).to eq("500")
      end
    end

    context "with ratio values" do
      it "formats values between 0 and 1 as percentages" do
        expect(helper.format_stat_value(0.8567)).to eq("85,67%")
      end

      it "formats 0 as percentage" do
        expect(helper.format_stat_value(0.0)).to eq("0,00%")
      end

      it "formats 1 as percentage" do
        expect(helper.format_stat_value(1.0)).to eq("100,00%")
      end

      it "formats small ratio values as percentages" do
        expect(helper.format_stat_value(0.05)).to eq("5,00%")
      end
    end

    context "with integer values" do
      it "formats small integers with delimiter" do
        expect(helper.format_stat_value(123)).to eq("123")
      end

      it "formats large integers with delimiter" do
        expect(helper.format_stat_value(1_234_567)).to eq("1 234 567")
      end
    end

    context "with decimal values" do
      it "formats small decimal values with precision" do
        expect(helper.format_stat_value(123.456)).to eq("123,46")
      end

      it "formats large decimal values with delimiter and precision" do
        expect(helper.format_stat_value(1234.567)).to eq("1 234,57")
      end
    end
  end

  describe "#cell_background_color" do
    context "with non-numeric values" do
      it "returns empty string for nil" do
        expect(helper.send(:cell_background_color, nil)).to eq("")
      end

      it "returns empty string for string" do
        expect(helper.send(:cell_background_color, "text")).to eq("")
      end
    end

    context "with non-ratio numeric values" do
      it "returns empty string for values > 1" do
        expect(helper.send(:cell_background_color, 1.5)).to eq("")
      end

      it "returns empty string for negative values" do
        expect(helper.send(:cell_background_color, -0.5)).to eq("")
      end

      it "returns empty string for large integers" do
        expect(helper.send(:cell_background_color, 100)).to eq("")
      end
    end

    context "with ratio values" do
      it "returns success color for value >= 0.8" do
        expect(helper.send(:cell_background_color, 0.8))
          .to eq("background-color: var(--success-950-100);")
        expect(helper.send(:cell_background_color, 0.95))
          .to eq("background-color: var(--success-950-100);")
        expect(helper.send(:cell_background_color, 1.0))
          .to eq("background-color: var(--success-950-100);")
      end

      it "returns yellow light color for value >= 0.5 and < 0.8" do
        expect(helper.send(:cell_background_color, 0.5))
          .to eq("background-color: var(--yellow-tournesol-975-75);")
        expect(helper.send(:cell_background_color, 0.7))
          .to eq("background-color: var(--yellow-tournesol-975-75);")
        expect(helper.send(:cell_background_color, 0.79))
          .to eq("background-color: var(--yellow-tournesol-975-75);")
      end

      it "returns yellow dark color for value >= 0.2 and < 0.5" do
        expect(helper.send(:cell_background_color, 0.2))
          .to eq("background-color: var(--yellow-tournesol-850-200);")
        expect(helper.send(:cell_background_color, 0.35))
          .to eq("background-color: var(--yellow-tournesol-850-200);")
        expect(helper.send(:cell_background_color, 0.49))
          .to eq("background-color: var(--yellow-tournesol-850-200);")
      end

      it "returns red color for value < 0.2" do
        expect(helper.send(:cell_background_color, 0.0))
          .to eq("background-color: var(--red-marianne-950-100);")
        expect(helper.send(:cell_background_color, 0.1))
          .to eq("background-color: var(--red-marianne-950-100);")
        expect(helper.send(:cell_background_color, 0.19))
          .to eq("background-color: var(--red-marianne-950-100);")
      end
    end
  end

  describe "#column_empty?" do
    let(:data_with_values) do
      [
        ["Header 1", "Header 2", "Header 3"],
        [100, 200, 300],
        [150, 250, 350]
      ]
    end

    let(:data_with_nil_column) do
      [
        ["Header 1", "Header 2", "Header 3"],
        [100, nil, 300],
        [150, nil, 350]
      ]
    end

    let(:data_with_nan_column) do
      [
        ["Header 1", "Header 2", "Header 3"],
        [100, Float::NAN, 300],
        [150, Float::NAN, 350]
      ]
    end

    let(:data_with_mixed_empty_column) do
      [
        ["Header 1", "Header 2", "Header 3"],
        [100, nil, 300],
        [150, Float::NAN, 350]
      ]
    end

    let(:data_with_partial_values) do
      [
        ["Header 1", "Header 2", "Header 3"],
        [100, nil, 300],
        [150, 250, 350]
      ]
    end

    it "returns false when column has values" do
      expect(helper.send(:column_empty?, data_with_values, 1)).to be false
    end

    it "returns true when column has only nil values" do
      expect(helper.send(:column_empty?, data_with_nil_column, 1)).to be true
    end

    it "returns true when column has only NaN values" do
      expect(helper.send(:column_empty?, data_with_nan_column, 1)).to be true
    end

    it "returns true when column has mix of nil and NaN values" do
      expect(helper.send(:column_empty?, data_with_mixed_empty_column, 1)).to be true
    end

    it "returns false when column has at least one real value" do
      expect(helper.send(:column_empty?, data_with_partial_values, 1)).to be false
    end

    it "skips the header row when checking" do
      data_with_header_value = [
        ["Header 1", "Actual Value", "Header 3"],
        [100, nil, 300],
        [150, nil, 350]
      ]
      expect(helper.send(:column_empty?, data_with_header_value, 1)).to be true
    end
  end

  describe "#visible_columns" do
    context "with empty data" do
      it "returns empty array" do
        expect(helper.send(:visible_columns, [])).to eq([])
      end
    end

    context "with all visible columns" do
      let(:data) do
        [
          ["Header 1", "Header 2", "Header 3"],
          [100, 200, 300],
          [150, 250, 350]
        ]
      end

      it "returns all column indices" do
        expect(helper.send(:visible_columns, data)).to eq([0, 1, 2])
      end
    end

    context "with some empty columns" do
      let(:data) do
        [
          ["Header 1", "Header 2", "Header 3", "Header 4"],
          [100, nil, 300, Float::NAN],
          [150, nil, 350, Float::NAN]
        ]
      end

      it "returns only non-empty column indices" do
        expect(helper.send(:visible_columns, data)).to eq([0, 2])
      end
    end

    context "with mixed empty columns" do
      let(:data) do
        [
          %w[H1 H2 H3 H4 H5],
          [100, nil, 300, Float::NAN, 500],
          [150, Float::NAN, 350, nil, 550]
        ]
      end

      it "returns indices of columns with at least one value" do
        expect(helper.send(:visible_columns, data)).to eq([0, 2, 4])
      end
    end

    context "with only headers" do
      let(:data) do
        [
          ["Header 1", "Header 2", "Header 3"]
        ]
      end

      it "returns empty array when no data rows exist" do
        expect(helper.send(:visible_columns, data)).to eq([])
      end
    end
  end
end
