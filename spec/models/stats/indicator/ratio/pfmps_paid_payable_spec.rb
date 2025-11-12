# frozen_string_literal: true

require "rails_helper"
require "./spec/models/stats/shared_contexts"

describe Stats::Indicator::Ratio::PfmpsPaidPayable do
  let(:current_start_year) { SchoolYear.current.start_year }
  let(:indicator) { Stats::Main.new(current_start_year).indicators[:pfmps_paid_payable_ratio] }

  describe "#global_data" do
    subject(:ratio_data) { indicator.global_data }

    context "when no PFMPs are payable" do
      it { is_expected.to be_nan }
    end

    context "when there are payable PFMPs but none paid" do
      include_context "when there is data for payable stats globally"

      it { is_expected.to eq(0.0) }
    end

    context "when all payable PFMPs are paid" do
      before do
        mef = create(:mef, daily_rate: 1, yearly_cap: 100)
        establishment = create(:establishment)
        classe = create(:classe, mef: mef, establishment: establishment)
        school_year_range = establishment.school_year_range(classe.school_year.start_year)

        3.times do
          student = create(:student, :asp_ready, establishment: establishment)
          schooling = create(:schooling, :with_attributive_decision, classe: classe, student: student)
          schooling.update!(start_date: school_year_range.first, end_date: school_year_range.last)
          pfmp = create(:pfmp, :validated, schooling: schooling, day_count: 5,
                                           start_date: 1.month.ago, end_date: 1.week.ago)
          create(:asp_payment_request, :paid, pfmp: pfmp)
        end
      end

      it "returns 1.0 (100%)" do
        expect(ratio_data).to eq(1.0)
      end
    end

    context "when some payable PFMPs are paid" do
      before do
        mef = create(:mef, daily_rate: 1, yearly_cap: 100)
        establishment = create(:establishment)
        classe = create(:classe, mef: mef, establishment: establishment)
        school_year_range = establishment.school_year_range(classe.school_year.start_year)

        5.times do
          student = create(:student, :asp_ready, establishment: establishment)
          schooling = create(:schooling, :with_attributive_decision, classe: classe, student: student)
          schooling.update!(start_date: school_year_range.first, end_date: school_year_range.last)
          create(:pfmp, :validated, schooling: schooling, day_count: 5,
                                    start_date: 1.month.ago, end_date: 1.week.ago)
        end

        2.times do
          student = create(:student, :asp_ready, establishment: establishment)
          schooling = create(:schooling, :with_attributive_decision, classe: classe, student: student)
          schooling.update!(start_date: school_year_range.first, end_date: school_year_range.last)
          pfmp = create(:pfmp, :validated, schooling: schooling, day_count: 5,
                                           start_date: 1.month.ago, end_date: 1.week.ago)
          create(:asp_payment_request, :paid, pfmp: pfmp)
        end
      end

      it "returns correct ratio (2/7 ≈ 0.286)" do
        expect(ratio_data).to be_within(0.001).of(2.0 / 7.0)
      end

      it "never exceeds 100%" do
        expect(ratio_data).to be <= 1.0
      end
    end

    context "when there are paid PFMPs that don't meet payable criteria" do
      before do
        mef = create(:mef, daily_rate: 1, yearly_cap: 100)
        establishment = create(:establishment)
        classe = create(:classe, mef: mef, establishment: establishment)
        school_year_range = establishment.school_year_range(classe.school_year.start_year)

        3.times do
          student = create(:student, :asp_ready, establishment: establishment)
          schooling = create(:schooling, :with_attributive_decision, classe: classe, student: student)
          schooling.update!(start_date: school_year_range.first, end_date: school_year_range.last)
          pfmp = create(:pfmp, :validated, schooling: schooling, day_count: 5,
                                           start_date: 1.month.ago, end_date: 1.week.ago)
          create(:asp_payment_request, :paid, pfmp: pfmp)
        end

        2.times do
          student = create(:student, :asp_ready, establishment: establishment)
          schooling = create(:schooling, classe: classe, student: student)
          schooling.update!(start_date: school_year_range.first, end_date: school_year_range.last)
          pfmp = create(:pfmp, :validated, schooling: schooling, day_count: 5,
                                           start_date: 1.month.ago, end_date: 1.week.ago)
          create(:asp_payment_request, :paid, pfmp: pfmp)
        end
      end

      it "only counts paid PFMPs that meet payable criteria" do
        expect(ratio_data).to eq(1.0)
      end

      it "never exceeds 100%" do
        expect(ratio_data).to be <= 1.0
      end
    end

    context "when dealing with edge cases" do
      before do
        mef = create(:mef, daily_rate: 1, yearly_cap: 100)
        establishment = create(:establishment)
        classe = create(:classe, mef: mef, establishment: establishment)
        school_year_range = establishment.school_year_range(classe.school_year.start_year)

        10.times do
          student = create(:student, :asp_ready, establishment: establishment)
          schooling = create(:schooling, :with_attributive_decision, classe: classe, student: student)
          schooling.update!(start_date: school_year_range.first, end_date: school_year_range.last)
          pfmp = create(:pfmp, :validated, schooling: schooling, day_count: 5,
                                           start_date: 1.month.ago, end_date: 1.week.ago)
          create(:asp_payment_request, :paid, pfmp: pfmp)
        end
      end

      it "handles large datasets without exceeding 100%" do
        expect(ratio_data).to eq(1.0)
        expect(ratio_data).to be <= 1.0
      end
    end
  end

  describe "#bops_data" do
    subject(:bops_ratio_data) { indicator.bops_data }

    include_context "when there is data for payable stats per bops"

    it { is_expected.to eq({ "ARMEE" => 0.0, "ENPR" => 0.0, "ENPU" => 0.0, "MASA" => 0.0, "MER" => 0.0 }) }

    it "never has ratios exceeding 100%" do
      bops_ratio_data.each_value do |ratio|
        expect(ratio).to be <= 1.0 unless ratio.nan?
      end
    end
  end

  describe "#menj_academies_data" do
    subject(:academies_ratio_data) { indicator.menj_academies_data }

    include_context "when there is data for payable stats per MENJ academies"

    it { is_expected.to eq({ "Bordeaux" => 1.0, "Montpellier" => 1.0, "Paris" => 1.0 }) }

    it "never has ratios exceeding 100%" do
      academies_ratio_data.each_value do |ratio|
        expect(ratio).to be <= 1.0 unless ratio.nan?
      end
    end
  end

  describe "#establishments_data" do
    subject(:establishments_ratio_data) { indicator.establishments_data }

    include_context "when there is data for payable stats per establishments"

    it { is_expected.to eq({ "0000000A" => 1.0, "0000000B" => 1.0, "0000000C" => 1.0 }) }

    it "never has ratios exceeding 100%" do
      establishments_ratio_data.each_value do |ratio|
        expect(ratio).to be <= 1.0 unless ratio.nan?
      end
    end
  end
end
