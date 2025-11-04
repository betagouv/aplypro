# frozen_string_literal: true

require "rails_helper"
require "./spec/models/stats/shared_contexts"

describe Stats::Indicator::Count::PfmpsPayable do
  let(:current_start_year) { SchoolYear.current.start_year }

  describe "#global_data" do
    subject { described_class.new(current_start_year).global_data }

    let(:previous_school_year) do
      SchoolYear.find_by!(start_year: previous_start_year)
    end

    let(:previous_start_year) { current_start_year - 1 }

    context "when one school year" do
      include_context "when there is data for payable stats globally"

      it { is_expected.to eq 2 }
    end

    context "when there are PFMPs from different school years" do
      before do
        student = create(:student, :asp_ready)
        current_classe = create(:classe, school_year: SchoolYear.current)
        current_schooling = create(:schooling, :with_attributive_decision, student: student, classe: current_classe)
        create(:pfmp, :validated,
               day_count: 5,
               schooling: current_schooling,
               start_date: current_classe.establishment.school_year_range(current_classe.school_year.start_year).first + 1.day, # rubocop:disable Layout/LineLength
               end_date: current_classe.establishment.school_year_range(current_classe.school_year.start_year).first + 6.days) # rubocop:disable Layout/LineLength

        previous_classe = create(:classe, school_year: previous_school_year)
        previous_schooling = create(:schooling, :with_attributive_decision, :closed, student: student,
                                                                                     classe: previous_classe)
        create(:pfmp, :validated,
               day_count: 10,
               schooling: previous_schooling,
               start_date: previous_classe.establishment.school_year_range(previous_classe.school_year.start_year).first + 1.day, # rubocop:disable Layout/LineLength
               end_date: previous_classe.establishment.school_year_range(previous_classe.school_year.start_year).first + 11.days) # rubocop:disable Layout/LineLength
      end

      it "only counts PFMPs from the selected school year" do
        expect(described_class.new(previous_start_year).global_data).to eq(1)
      end
    end
  end

  describe "#bops_data" do
    subject { described_class.new(current_start_year).bops_data }

    include_context "when there is data for payable stats per bops"

    it { is_expected.to eq({ "ENPU" => 1, "MASA" => 2, "ARMEE" => 3, "MER" => 4, "ENPR" => 4 }) }
  end

  describe "#menj_academies_data" do
    subject { described_class.new(current_start_year).menj_academies_data }

    include_context "when there is data for payable stats per MENJ academies"

    it { is_expected.to eq({ "Bordeaux" => 1, "Montpellier" => 3, "Paris" => 2 }) }
  end

  describe "#establishments_data" do
    subject { described_class.new(current_start_year).establishments_data }

    include_context "when there is data for payable stats per establishments"

    it { is_expected.to eq({ "0000000A" => 1, "0000000B" => 3, "0000000C" => 2 }) }
  end
end
