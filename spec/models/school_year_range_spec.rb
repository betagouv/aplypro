# frozen_string_literal: true

require "rails_helper"

RSpec.describe SchoolYearRange do
  describe "associations" do
    it { is_expected.to belong_to(:school_year) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:academy_code) }
  end

  describe "#range" do
    context "when there is no parameter" do
      it "returns the current school year range" do
        expect(described_class.range).to eq(Date.new(2024, 9, 2)..Date.new(2025, 8, 31))
      end
    end

    context "when the school_year is in the DB" do
      let(:school_year) { SchoolYear.find_by(start_year: 2023) }

      it "returns the associated school year range" do
        expect(described_class.range(school_year)).to eq(Date.new(2023, 9, 4)..Date.new(2024, 9, 1))
      end
    end

    context "when the school_year is not in the DB" do
      let(:school_year) { SchoolYear.find_or_create_by!(start_year: 2019) }

      it "returns the default school year range" do
        expect(described_class.range(school_year)).to eq(Date.new(2019, 9, 1)..Date.new(2020, 8, 31))
      end
    end

    context "when the academy_code is in the DB" do
      let(:school_year) { SchoolYear.find_by(start_year: 2023) }

      it "returns the associated school year range" do
        expect(described_class.range(school_year, "28")).to eq(Date.new(2023, 8, 17)..Date.new(2024, 8, 18))
      end
    end

    context "when the academy_code is not in the DB" do
      let(:school_year) { SchoolYear.find_by(start_year: 2023) }

      it "returns the metropolitan school year range" do
        expect(described_class.range(school_year, "14")).to eq(Date.new(2023, 9, 4)..Date.new(2024, 9, 1))
      end
    end
  end
end
