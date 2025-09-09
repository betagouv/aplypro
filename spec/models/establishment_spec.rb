# frozen_string_literal: true

require "rails_helper"
require "csv"

RSpec.describe Establishment do
  subject(:establishment) { build(:establishment, :sygne_provider) }

  it { is_expected.to validate_presence_of(:uai) }
  it { is_expected.to validate_uniqueness_of(:uai) }
  it { is_expected.to have_many(:ribs) }
  it { is_expected.to validate_inclusion_of(:students_provider).in_array(Establishment::PROVIDERS) }

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

  describe "#school_year_range" do
    subject(:establishment) { create(:establishment, academy_code: academy_code) }

    context "when the establishment has a default academy_code" do
      let(:academy_code) { "14" }

      it "returns the current school year range" do
        expect(establishment.school_year_range).to eq(Date.new(2024, 9, 2)..Date.new(2025, 8, 31))
      end
    end

    context "when the establishment has a academy_code in SchoolYearRanges" do
      let(:academy_code) { "28" }
      let(:expected_start_date) { Date.new(2023, 8, 17) }
      let(:expected_end_date) { Date.new(2024, 8, 18) }

      it "returns the school year range based on the exception" do
        expect(establishment.school_year_range(2023)).to eq(expected_start_date..expected_end_date)
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

    it "returns empty when search string is blank?" do
      expect(etab.find_students("   ")).to be_empty
    end
  end

  describe "#in_current_school_year_range?" do
    subject { establishment.in_current_school_year_range?(start_date) }

    context "when there is no start date" do
      let(:start_date) { nil }

      it { is_expected.to be false }
    end

    context "when the start date is before the current school year range" do
      let(:start_date) { Date.parse("#{SchoolYear.current.start_year}-01-30") }

      it { is_expected.to be false }
    end

    context "when the start date is equal to the current school year range" do
      let(:start_date) { Date.parse("#{SchoolYear.current.start_year}-09-30") }

      it { is_expected.to be true }
    end
  end
end
