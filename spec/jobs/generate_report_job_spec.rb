# frozen_string_literal: true

require "rails_helper"

RSpec.describe GenerateReportJob do
  describe "#perform" do
    let(:school_year) { create(:school_year, start_year: 2070) }
    let(:date) { Time.current }

    before do
      allow(Report).to receive(:create_for_school_year).and_call_original
      allow(SchoolYear).to receive(:current).and_return(school_year)
      allow(Stats::Main).to receive(:new)
        .and_return(instance_double(Stats::Main,
                                    global_data: [],
                                    bops_data: [{ BOP: "ENPR", "Coord. bancaires": 4 }],
                                    menj_academies_data: [{ Académie: "Data1" }, { Académie: "Data2" }],
                                    establishments_data: [{ UAI: "123456", "Nom de l'établissement": "Test" }]))
    end

    it "creates a report with the provided date" do
      expect { described_class.new.perform(school_year, date) }.to change(Report, :count).by(1)
      expect(Report.last.created_at).to be_within(1.second).of(date)
      expect(Report.last.school_year).to eq(school_year)
    end

    it "creates a report with current time when no date provided" do
      expect { described_class.new.perform(school_year) }.to change(Report, :count).by(1)
    end

    it "creates a report when none exists for the date" do
      expect { described_class.new.perform(school_year, date) }.to change(Report, :count).by(1)
    end

    it "does not create a duplicate report for the same date" do
      create(:report, created_at: date, school_year: school_year)
      expect { described_class.new.perform(school_year, date) }.not_to change(Report, :count)
    end
  end
end
