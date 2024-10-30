# frozen_string_literal: true

require "rails_helper"

# rubocop:disable RSpec/EmptyExampleGroup
# rubocop:disable RSpec/MultipleMemoizedHelpers
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

  let(:mef) { create(:mef, daily_rate: 1, yearly_cap: 10, school_year: SchoolYear.current) }
  let(:classe) { create(:classe, school_year: SchoolYear.current, mef: mef) }

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
    pfmp.schooling.update!(classe: classe)
  end

  context "when the PFMP doesn't have a day count" do
    before { pfmp.update!(day_count: nil) }

    it { is_expected.to be_zero }
  end

  it_calculates "the original amount"

  context "when the PFMP goes over the yearly cap" do
    before do
      pfmp.update!(day_count: 200)
    end

    it_calculates "the yearly-capped amount"
  end

  context "when there is a previous PFMP" do
    let(:previous) { create(:pfmp, :completed, day_count: 8, created_at: Date.yesterday) }

    context "with another schooling" do
      let(:schooling) { create(:schooling, :closed, student: pfmp.student) }

      before { previous.update!(schooling: schooling) }

      context "with the same MEF" do
        before do
          schooling.classe.update!(mef: mef)
        end

        it "errors when trying to recalculate" do
          expect { PfmpManager.new(previous.reload).recalculate_amounts! }.to raise_error ActiveRecord::RecordInvalid
        end

        context "when the classe is from another year" do
          before do
            old_school_year = create(:school_year, start_year: 2022)
            old_classe = create(:classe, school_year: old_school_year)

            schooling.update!(classe: old_classe)
          end

          it_calculates "the original amount"
        end
      end

      context "with another MEF" do
        it_calculates "the original amount"
      end
    end

    context "with that schooling" do
      it "errors" do
        expect { previous.update!(schooling: pfmp.schooling) }.to raise_error ActiveRecord::RecordInvalid
      end
    end
  end

  describe "#other_pfmps" do
    let(:student) { create(:student, :with_all_asp_info) }
    let(:schooling) { create(:schooling, student: student, classe: classe) }
    let(:pfmp) do
      create(:pfmp,
             :validated,
             start_date: "2024-09-03",
             end_date: "2024-09-28",
             schooling: schooling,
             day_count: 3)
    end

    before do
      old_school_year = create(:school_year, start_year: 2022)
      old_classe = create(:classe, school_year: old_school_year)
      old_schooling = create(:schooling, :closed, student: student, classe: old_classe)
      create(:pfmp,
             :validated,
             start_date: "#{old_school_year.start_year}-09-03",
             end_date: "#{old_school_year.start_year}-09-28",
             schooling: old_schooling,
             day_count: 1)
    end

    it "returns the PFMP for the MEF and the current school year" do
      expect(pfmp.other_pfmps).to contain_exactly(pfmp)
    end
  end
end
# rubocop:enable RSpec/EmptyExampleGroup
# rubocop:enable RSpec/MultipleMemoizedHelpers
