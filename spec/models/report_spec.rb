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

    describe "data schema validation" do
      let(:valid_data) do
        {
          "global_data" => [
            Report::HEADERS,
            Array.new(Report::HEADERS.length, nil)
          ],
          "bops_data" => [
            [:bop] + Report::HEADERS,
            ["ENPU"] + Array.new(Report::HEADERS.length, nil)
          ],
          "menj_academies_data" => [
            [:academy] + Report::HEADERS,
            ["Paris"] + Array.new(Report::HEADERS.length, nil)
          ],
          "establishments_data" => [
            %i[uai establishment_name ministry academy private_or_public] + Report::HEADERS,
            ["0010001A", "Lycée Test", "MENJ", "Paris", "Public"] + Array.new(Report::HEADERS.length, nil)
          ]
        }
      end

      it "is valid with correct schema" do
        report = build(:report, :with_schema_validation, data: valid_data)
        expect(report).to be_valid
      end

      it "allows partial data for test purposes when validation disabled" do
        report = build(:report, data: valid_data.except("global_data"))
        expect(report).to be_valid
      end

      it "rejects data with missing sections" do
        report = build(:report, :with_schema_validation, data: valid_data.except("global_data"))
        expect(report).not_to be_valid
        expect(report.errors[:data]).to include(/global_data is missing/)
      end

      it "rejects data with non-array values" do
        invalid_data = valid_data.merge("global_data" => "not an array")
        report = build(:report, :with_schema_validation, data: invalid_data)
        expect(report).not_to be_valid
      end

      it "rejects data with incorrect global_data header" do
        invalid_data = valid_data.dup
        invalid_data["global_data"] = [
          %w[Wrong Header],
          Array.new(Report::HEADERS.length, nil)
        ]
        report = build(:report, :with_schema_validation, data: invalid_data)
        expect(report).not_to be_valid
        expect(report.errors[:data]).to include(/global_data header must be/)
      end

      it "rejects data with incorrect bops_data header" do
        invalid_data = valid_data.dup
        invalid_data["bops_data"] = [
          ["Wrong"] + Report::HEADERS,
          ["ENPU"] + Array.new(Report::HEADERS.length, nil)
        ]
        report = build(:report, :with_schema_validation, data: invalid_data)
        expect(report).not_to be_valid
        expect(report.errors[:data]).to include(/bops_data header must be/)
      end

      it "rejects data with incorrect row length" do
        invalid_data = valid_data.dup
        invalid_data["global_data"] = [
          Report::HEADERS,
          [1, 2, 3]
        ]
        report = build(:report, :with_schema_validation, data: invalid_data)
        expect(report).not_to be_valid
        expect(report.errors[:data]).to include(/global_data row 1 must have/)
      end

      it "rejects establishments_data with wrong header" do
        invalid_data = valid_data.dup
        invalid_data["establishments_data"] = [
          %w[UAI Wrong] + Report::HEADERS,
          ["0010001A", "Lycée Test", "MENJ", "Paris", "Public"] + Array.new(Report::HEADERS.length, nil)
        ]
        report = build(:report, :with_schema_validation, data: invalid_data)
        expect(report).not_to be_valid
        expect(report.errors[:data]).to include(/establishments_data header must be/)
      end

      it "rejects data with arrays that are too small" do
        invalid_data = valid_data.dup
        invalid_data["global_data"] = [Report::HEADERS]
        report = build(:report, :with_schema_validation, data: invalid_data)
        expect(report).not_to be_valid
      end
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
                                      bops_data: [{ bop: "ENPR", ribs_count: 4 }],
                                      menj_academies_data: [{ academy: "Data1" }, { academy: "Data2" }],
                                      establishments_data: [{ uai: "123456", establishment_name: "Test" }]))
      end

      it "creates a new report" do
        expect { described_class.create_for_school_year(create_for_date_school_year, date) }
          .to change(described_class, :count).by(1)
      end

      it "sets the correct data" do
        described_class.create_for_school_year(create_for_date_school_year, date)

        report = described_class.last
        keys = Report::HEADERS.map(&:to_s)

        expect(report.data.keys).to contain_exactly("global_data", "bops_data", "menj_academies_data",
                                                    "establishments_data")
        expect(report.data["global_data"].first).to eq(keys)
        expect(report.data["bops_data"].first).to eq(["bop"] + keys)
        expect(report.data["menj_academies_data"].first).to eq(["academy"] + keys)
        establishments_keys = %w[uai establishment_name ministry academy private_or_public]
        expect(report.data["establishments_data"].first).to eq(establishments_keys + keys)
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
