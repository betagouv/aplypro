# frozen_string_literal: true

require "rails_helper"

RSpec.describe Report do
  describe "validations" do
    subject { build(:report) }

    it { is_expected.to validate_presence_of(:data) }
    it { is_expected.to validate_presence_of(:created_at) }

    describe "uniqueness of created_at" do
      before { create(:report, school_year: create(:school_year, start_year: 2060)) }

      it { is_expected.to validate_uniqueness_of(:created_at).scoped_to(:school_year_id) }
    end
  end

  describe "scopes" do
    let(:scope_school_year) { create(:school_year, start_year: 2050) }
    let!(:older_report) { create(:report, created_at: 2.days.ago, school_year: scope_school_year) }
    let!(:newer_report) { create(:report, created_at: 1.day.ago, school_year: scope_school_year) }

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
    let(:nav_school_year) { create(:school_year, start_year: 2030) }
    let(:oldest_report) { create(:report, created_at: 3.days.ago, school_year: nav_school_year) }
    let(:middle_report) { create(:report, created_at: 2.days.ago, school_year: nav_school_year) }

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
    let(:nav_school_year) { create(:school_year, start_year: 2031) }
    let(:middle_report) { create(:report, created_at: 2.days.ago, school_year: nav_school_year) }
    let(:newest_report) { create(:report, created_at: 1.day.ago, school_year: nav_school_year) }

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
    let(:create_for_date_school_year) { create(:school_year, start_year: 2040) }

    context "when no report exists for the date" do
      before do
        allow(Stats::Main).to receive(:new)
          .and_return(instance_double(Stats::Main,
                                      global_data: [],
                                      bops_data: [{ BOP: "ENPR", "Coord. bancaires": 4 }],
                                      menj_academies_data: [{ Académie: "Data1" }, { Académie: "Data2" }],
                                      establishments_data: [{ UAI: "123456", "Nom de l'établissement": "Test" }]))
      end

      it "creates a new report" do
        expect { described_class.create_for_school_year(create_for_date_school_year, date) }
          .to change(described_class, :count).by(1)
      end

      it "sets the correct data" do # rubocop:disable RSpec/ExampleLength
        described_class.create_for_school_year(create_for_date_school_year, date)

        report = described_class.last
        keys = Report::GENERIC_DATA_KEYS

        expect(report.data).to include("global_data" => [keys, Array.new(keys.size, nil)],
                                       "bops_data" => [["BOP"] + keys,
                                                       ["ENPR", nil, 4] + Array.new(keys.size - 2, nil)],
                                       "menj_academies_data" => [["Académie"] + keys,
                                                                 ["Data1"] + Array.new(keys.size, nil),
                                                                 ["Data2"] + Array.new(keys.size, nil)],
                                       "establishments_data" => [["UAI", "Nom de l'établissement", "Ministère",
                                                                  "Académie", "Privé/Public"] + keys,
                                                                 %w[123456 Test] + Array.new(keys.size + 3, nil)])
      end
    end

    context "when a report already exists for the date" do
      before do
        create(:report, created_at: date, school_year: create_for_date_school_year)
      end

      it "does not create a new report" do
        expect { described_class.create_for_school_year(create_for_date_school_year, date) }
          .not_to change(described_class, :count)
      end
    end
  end
end
