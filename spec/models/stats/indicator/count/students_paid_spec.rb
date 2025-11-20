# frozen_string_literal: true

require "rails_helper"

describe Stats::Indicator::Count::StudentsPaid do
  let(:current_start_year) { SchoolYear.current.start_year }
  let(:current_school_year) { SchoolYear.current }

  describe "#global_data" do
    subject(:result) { described_class.new(current_start_year).global_data }

    before do
      mef = create(:mef, daily_rate: 10, yearly_cap: 500)
      establishment = create(:establishment)
      classe = create(:classe, mef: mef, establishment: establishment, school_year: current_school_year)
      school_year_range = establishment.school_year_range(current_start_year)

      2.times do
        student = create(:student, :asp_ready, establishment: establishment)
        schooling = create(:schooling, :with_attributive_decision, classe: classe, student: student)
        schooling.update!(start_date: school_year_range.first, end_date: school_year_range.last)
        pfmp = create(:pfmp, :validated, schooling: schooling, day_count: 5,
                                         start_date: school_year_range.first + 1.day,
                                         end_date: school_year_range.first + 6.days)
        create(:asp_payment_request, :paid, pfmp: pfmp)
      end

      student_unpaid = create(:student, :asp_ready, establishment: establishment)
      schooling_unpaid = create(:schooling, :with_attributive_decision, classe: classe, student: student_unpaid)
      schooling_unpaid.update!(start_date: school_year_range.first, end_date: school_year_range.last)
      create(:pfmp, :validated, schooling: schooling_unpaid, day_count: 5,
                                start_date: school_year_range.first + 1.day,
                                end_date: school_year_range.first + 6.days)
    end

    it "counts only students with paid payment requests" do
      expect(result).to eq(2)
    end
  end
end
