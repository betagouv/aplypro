# frozen_string_literal: true

require "rails_helper"

RSpec.describe Report do
  let(:sample_data) do
    {
      "global_data" => [["Header"], ["Data"]],
      "bops_data" => [["BOP Header"], ["BOP Data"]],
      "menj_academies_data" => [["Academy Header"], ["Academy Data"]],
      "establishments_data" => [["Establishment Header"], ["Establishment Data"]]
    }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:data) }
    it { is_expected.to validate_presence_of(:created_at) }
    it { is_expected.to validate_uniqueness_of(:created_at) }
  end

  describe "scopes" do
    let!(:older_report) { create(:report, created_at: 2.days.ago) }
    let!(:newer_report) { create(:report, created_at: 1.day.ago) }

    describe ".ordered" do
      it "returns reports ordered by created_at desc" do
        expect(described_class.ordered).to eq([newer_report, older_report])
      end
    end

    describe ".latest" do
      it "returns the most recent report" do
        expect(described_class.latest).to eq(newer_report)
      end

      it "returns nil when no reports exist" do
        described_class.destroy_all
        expect(described_class.latest).to be_nil
      end
    end
  end

  describe "#previous_report" do
    let(:oldest_report) { create(:report, created_at: 3.days.ago) }
    let(:middle_report) { create(:report, created_at: 2.days.ago) }

    before do
      oldest_report
      middle_report
    end

    it "returns the previous report" do
      expect(middle_report.previous_report).to eq(oldest_report)
    end

    it "returns nil for the oldest report" do
      expect(oldest_report.previous_report).to be_nil
    end
  end

  describe "#next_report" do
    let(:middle_report) { create(:report, created_at: 2.days.ago) }
    let(:newest_report) { create(:report, created_at: 1.day.ago) }

    before do
      middle_report
      newest_report
    end

    it "returns the next report" do
      expect(middle_report.next_report).to eq(newest_report)
    end

    it "returns nil for the newest report" do
      expect(newest_report.next_report).to be_nil
    end
  end

  describe ".create_for_date" do
    let(:date) { Time.current }

    context "when no report exists for the date" do
      before do
        allow(SchoolYear).to receive(:current).and_return(instance_double(SchoolYear, start_year: 2024))
        allow(Stats::Main).to receive(:new).and_return(instance_double(Stats::Main,
                                                                       global_data: [["Global"]],
                                                                       bops_data: [["BOP"]],
                                                                       menj_academies_data: [["Academy"]],
                                                                       establishments_data: [["Establishment"]]))
      end

      it "creates a new report" do
        expect { described_class.create_for_date(date) }.to change(described_class, :count).by(1)
      end

      it "sets the correct data" do
        described_class.create_for_date(date)
        report = described_class.last
        expect(report.data).to include(
          "global_data" => [["Global"]],
          "bops_data" => [["BOP"]],
          "menj_academies_data" => [["Academy"]],
          "establishments_data" => [["Establishment"]]
        )
      end
    end

    context "when a report already exists for the date" do
      before { create(:report, created_at: date) }

      it "does not create a new report" do
        expect { described_class.create_for_date(date) }.not_to change(described_class, :count)
      end
    end
  end
end
