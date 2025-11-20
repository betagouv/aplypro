# frozen_string_literal: true

require "rails_helper"

describe Stats::Indicator::Sum::PfmpsIncompleted do
  let(:current_start_year) { SchoolYear.current.start_year }
  let(:current_school_year) { SchoolYear.current }

  describe "#global_data" do
    subject(:result) { described_class.new(current_start_year).global_data }

    context "with incomplete PFMPs" do
      before do
        mef = create(:mef, daily_rate: 10, yearly_cap: 500)
        establishment = create(:establishment)
        classe = create(:classe, mef: mef, establishment: establishment, school_year: current_school_year)
        school_year_range = establishment.school_year_range(current_start_year)

        student = create(:student, :asp_ready, establishment: establishment)
        schooling = create(:schooling, :with_attributive_decision, classe: classe, student: student)
        schooling.update!(start_date: school_year_range.first, end_date: school_year_range.last)

        create(:pfmp, schooling: schooling, amount: 999,
                      start_date: school_year_range.first + 1.day,
                      end_date: school_year_range.first + 8.days)
      end

      it "calculates theoretical amount using (duration * 5/7) * daily_rate" do
        duration = 7
        expected_workdays = (duration * 5.0 / 7.0).round
        expected_amount = expected_workdays * 10

        expect(result).to eq(expected_amount)
      end
    end

    context "with multiple incomplete PFMPs" do
      before do
        mef = create(:mef, daily_rate: 15, yearly_cap: 500)
        establishment = create(:establishment)
        classe = create(:classe, mef: mef, establishment: establishment, school_year: current_school_year)
        school_year_range = establishment.school_year_range(current_start_year)

        2.times do
          student = create(:student, :asp_ready, establishment: establishment)
          schooling = create(:schooling, :with_attributive_decision, classe: classe, student: student)
          schooling.update!(start_date: school_year_range.first, end_date: school_year_range.last)

          create(:pfmp, schooling: schooling, amount: 100,
                        start_date: school_year_range.first + 1.day,
                        end_date: school_year_range.first + 15.days)
        end
      end

      it "sums theoretical amounts correctly" do
        duration = 14
        expected_workdays = (duration * 5.0 / 7.0).round
        expected_total = (expected_workdays * 15) * 2

        expect(result).to eq(expected_total)
      end
    end

    context "when PFMP is validated" do
      before do
        mef = create(:mef, daily_rate: 10, yearly_cap: 500)
        establishment = create(:establishment)
        classe = create(:classe, mef: mef, establishment: establishment, school_year: current_school_year)
        school_year_range = establishment.school_year_range(current_start_year)

        student = create(:student, :asp_ready, establishment: establishment)
        schooling = create(:schooling, :with_attributive_decision, classe: classe, student: student)
        schooling.update!(start_date: school_year_range.first, end_date: school_year_range.last)

        create(:pfmp, :validated, schooling: schooling, amount: 100,
                                  start_date: school_year_range.first + 1.day,
                                  end_date: school_year_range.first + 8.days)
      end

      it "excludes validated PFMPs" do
        expect(result).to eq(0)
      end
    end
  end

  describe "#bops_data" do
    subject(:bops_result) { described_class.new(current_start_year).bops_data }

    before do
      establishment = create(:establishment)

      Mef.ministries.each_key.with_index do |ministry, index|
        mef = create(:mef, ministry: ministry, daily_rate: 10, yearly_cap: 500)
        school_year_range = establishment.school_year_range(current_start_year)
        classe = create(:classe, mef: mef, establishment: establishment, school_year: current_school_year)

        (index + 1).times do
          student = create(:student, :asp_ready, establishment: establishment)
          schooling = create(:schooling, :with_attributive_decision, classe: classe, student: student)
          schooling.update!(start_date: school_year_range.first, end_date: school_year_range.last)

          create(:pfmp, schooling: schooling, amount: 100,
                        start_date: school_year_range.first + 1.day,
                        end_date: school_year_range.first + 8.days)
        end
      end
    end

    it "groups theoretical amounts by BOP" do
      workdays = (7 * 5.0 / 7.0).round
      amount = workdays * 10

      expect(bops_result).to include("ENPU" => amount, "MASA" => amount * 2)
    end
  end
end
