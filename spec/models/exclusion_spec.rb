# frozen_string_literal: true

require "rails_helper"

RSpec.describe Exclusion do
  describe "validation" do
    it { is_expected.to belong_to(:school_year).class_name("SchoolYear").optional }
    it { is_expected.to validate_presence_of(:uai) }
    it { is_expected.to validate_uniqueness_of(:uai).scoped_to(%i[mef_code school_year_id]) }

    it "cannot be equally the whole establishment and a specific diploma" do
      create(:exclusion, :whole_establishment, uai: "FOO")

      expect { create(:exclusion, uai: "FOO", mef_code: "BAR") }.to raise_error ActiveRecord::RecordInvalid
    end
  end

  describe "excluded?" do
    subject { described_class.excluded?(uai, mef_code, school_year) }

    let(:mef_code) { nil }
    let(:uai) { nil }
    let(:school_year) { nil }

    context "when the whole establishment is excluded" do
      let(:exclusion) { create(:exclusion, :whole_establishment) }

      let(:uai) { exclusion.uai }
      let(:school_year) { exclusion.school_year_id }

      it { is_expected.to be true }
    end

    context "when the establishment and that specific MEF is excluded" do
      let(:exclusion) { create(:exclusion, school_year: nil) }

      let(:uai) { exclusion.uai }
      let(:mef_code) { exclusion.mef_code }

      it { is_expected.to be true }
    end

    context "when the establishment, that specific MEF and that specific school year is excluded" do
      let(:exclusion) { create(:exclusion) }

      let(:uai) { exclusion.uai }
      let(:mef_code) { exclusion.mef_code }
      let(:school_year) { exclusion.school_year }

      it { is_expected.to be true }
    end

    context "when the establishment and another MEF are excluded" do
      let(:exclusion) { create(:exclusion) }

      let(:uai) { exclusion.uai }
      let(:mef_code) { "TEST" }

      it { is_expected.to be false }
    end
  end
end
