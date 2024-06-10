# frozen_string_literal: true

require "rails_helper"

describe PfmpAmountCalculator do
  subject(:amount) { pfmp.reload.calculate_amount }

  let(:establishment) { create(:establishment) }

  let(:pfmp) do
    start_date = establishment.school_year_range.first
    end_date = start_date >> 10
    create(
      :pfmp,
      start_date: start_date,
      end_date: end_date,
      day_count: 3
    )
  end

  let(:mef) { create(:mef, daily_rate: 1, yearly_cap: 10) }

  RSpec.configure do |config|
    config.alias_it_behaves_like_to(:it_calculates, "calculates")
  end

  RSpec.shared_examples "the original amount" do
    it { is_expected.to eq 3 }
  end

  RSpec.shared_examples "the yearly-capped amount" do
    it { is_expected.to eq 10 }
  end

  RSpec.shared_examples "a limited amount" do |amount|
    it { is_expected.to eq amount }
  end

  before do
    pfmp.schooling.classe.update!(mef: mef)
  end

  context "when the PFMP doesn't have a day count" do
    before { pfmp.update!(day_count: nil) }

    it { is_expected.to be_zero }
  end

  it_calculates "the original amount"

  describe "#pfmps_for_mef_and_school_year" do # rubocop:disable RSpec/MultipleMemoizedHelpers
    let(:mef) { create(:mef, daily_rate: 20, yearly_cap: 400) }
    let(:school_year) { create(:school_year, start_year: 2022) }
    let(:classe) { create(:classe, mef: mef, school_year: school_year) }
    let(:student) { create(:student, :with_all_asp_info) }
    let(:schooling) { create(:schooling, student: student, classe: classe) }
    let(:pfmp) do
      create(:pfmp,
             :validated,
             start_date: "#{school_year.start_year}-09-03",
             end_date: "#{school_year.start_year}-09-28",
             schooling: schooling,
             day_count: 3)
    end

    before do
      school_year = create(:school_year, start_year: 2020)
      classe = create(:classe, school_year: school_year, mef: mef)
      schooling = create(:schooling,
                         student: student,
                         classe: classe,
                         end_date: "#{SchoolYear.current.start_year}-08-27")
      create(:pfmp,
             :validated,
             start_date: "#{school_year.start_year}-09-03",
             end_date: "#{school_year.start_year}-09-28",
             schooling: schooling,
             day_count: 1)
    end

    it "returns the PFMP for the MEF and the current school year" do
      expect(pfmp.pfmps_for_mef_and_school_year).to contain_exactly(pfmp)
    end
  end
end
