# frozen_string_literal: true

require "rails_helper"
require "./spec/models/stats/shared_contexts"

describe Stats::Indicator::SendableAmounts do
  let(:current_start_year) { SchoolYear.current.start_year }

  describe "#global_data" do
    subject { described_class.new(current_start_year).global_data }

    let(:previous_school_year) do
      SchoolYear.find_by!(start_year: previous_start_year)
    end

    let(:previous_start_year) { current_start_year - 1 }

    context "when one school year" do
      include_context "when there is data for global stats"

      it { is_expected.to eq 10 }
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
        expect(described_class.new(previous_start_year).global_data).to eq(150)
      end
    end
  end

  describe "#bops_data" do
    subject { described_class.new(current_start_year).bops_data }

    include_context "when there is data for stats per bops"

    it { is_expected.to eq({ "ENPU" => 5.0, "ENPR" => 20, "MASA" => 10.0, "MER" => 20.0, "ARMEE" => 15.0 }) }
  end

  describe "#menj_academies_data" do
    subject { described_class.new(current_start_year).menj_academies_data }

    include_context "when there is data for stats per MENJ academies"

    it { is_expected.to eq({ "Bordeaux" => 5.0, "Montpellier" => 15.0, "Paris" => 10.0 }) }
  end

  describe "#establishments_data" do
    subject { described_class.new(current_start_year).establishments_data }

    include_context "when there is data for stats per establishments"

    it { is_expected.to eq({ "0000000A" => 5.0, "0000000B" => 15.0, "0000000C" => 10.0 }) }
  end
end
