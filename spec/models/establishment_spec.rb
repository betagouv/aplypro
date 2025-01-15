# frozen_string_literal: true

require "rails_helper"
require "csv"

RSpec.describe Establishment do
  subject(:establishment) { build(:establishment, :sygne_provider) }

  it { is_expected.to validate_presence_of(:uai) }
  it { is_expected.to validate_uniqueness_of(:uai) }
  it { is_expected.to have_many(:ribs) }

  describe "some_attributive_decisions?" do
    subject { establishment.some_attributive_decisions?(SchoolYear.current) }

    context "when there are some attributive decisions" do
      before { create(:schooling, :with_attributive_decision, establishment: establishment) }

      it { is_expected.to be_truthy }
    end

    context "when there are no attributive decisions" do
      before { create(:schooling, establishment: establishment) }

      it { is_expected.to be_falsey }
    end
  end

  describe "some_attributive_decisions_generating?" do
    context "when a schooling is marked for generation" do
      let(:schooling) { create(:schooling, establishment: establishment) }

      it "returns true" do
        expect { schooling.update!(generating_attributive_decision: true) }
          .to change { establishment.some_attributive_decisions_generating?(SchoolYear.current) }
          .from(false).to(true)
      end
    end
  end

  describe "confirmed_director" do
    let!(:user) { create(:user, :confirmed_director, establishment: establishment) }

    it { is_expected.to be_valid }

    context "when the confirmed_director is not a director" do
      before { user.establishment_user_roles.first.update(role: :authorised) }

      it { is_expected.not_to be_valid }
    end
  end

  describe "excluded?" do
    before do
      allow(Exclusion).to receive(:establishment_excluded?).and_return "a fake result"
    end

    it "forwards its UAI" do
      establishment.excluded?

      expect(Exclusion).to have_received(:establishment_excluded?).with(establishment.uai)
    end

    it "returns the result" do
      expect(establishment.excluded?).to eq "a fake result"
    end
  end

  describe "#school_year_range" do
    subject(:establishment) { create(:establishment, academy_code: academy_code) }

    context "when the establishment has a default academy_code" do
      let(:academy_code) { "14" }
      let(:start_date) { Date.parse("2024-09-01") }

      around do |example|
        Timecop.safe_mode = false
        Timecop.freeze(start_date) do
          example.run
        end
      end

      it "returns the default school year range" do
        expect(establishment.school_year_range).to eq(
          start_date..start_date >> 12
        )
      end
    end

    context "when the establishment has a academy_code with an exception" do
      let(:academy_code) { "28" }
      let(:expected_start_date) { Date.new(SchoolYear.current.start_year, 8, 16) }

      it "returns the school year range based on the exception" do
        expect(establishment.school_year_range).to eq(expected_start_date..expected_start_date >> 12)
      end
    end
  end

  describe "#find_students" do
    let(:etab) { create(:classe, :with_students, students_count: 5).establishment }

    before do
      etab.students.first.update!(first_name: "Tibal", last_name: "N'Guy-ôme")
    end

    it "strips apostrophes" do
      expect(etab.find_students("nguyom")).to contain_exactly(Student.find_by!(last_name: "N'Guy-ôme"))
    end

    it "finds students with partial names" do
      expect(etab.find_students("ibal")).to contain_exactly(Student.find_by!(first_name: "Tibal"))
    end
  end
end
