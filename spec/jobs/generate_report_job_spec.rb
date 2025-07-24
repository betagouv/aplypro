# frozen_string_literal: true

require "rails_helper"

RSpec.describe GenerateReportJob do
  describe "#perform" do
    let(:date) { Time.current }

    before do
      allow(Report).to receive(:create_for_date)
    end

    it "calls Report.create_for_date with the provided date" do
      described_class.new.perform(date)
      expect(Report).to have_received(:create_for_date).with(date)
    end

    it "calls Report.create_for_date with current time when no date provided" do
      described_class.new.perform
      expect(Report).to have_received(:create_for_date).once
    end

    context "when integrated with Report model" do
      before do
        allow(Report).to receive(:create_for_date).and_call_original
        allow(SchoolYear).to receive(:current).and_return(instance_double(SchoolYear, start_year: 2024))
        allow(Stats::Main).to receive(:new).and_return(instance_double(Stats::Main,
                                                                       global_data: [["Global"]],
                                                                       bops_data: [["BOP"]],
                                                                       menj_academies_data: [["Academy"]],
                                                                       establishments_data: [["Establishment"]]))
      end

      it "creates a report when none exists for the date" do
        expect { described_class.new.perform(date) }.to change(Report, :count).by(1)
      end

      it "does not create a duplicate report for the same date" do
        create(:report, created_at: date)
        expect { described_class.new.perform(date) }.not_to change(Report, :count)
      end
    end
  end
end
