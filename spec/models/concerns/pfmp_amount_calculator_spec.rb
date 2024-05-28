# frozen_string_literal: true

require "rails_helper"

# Rubocop doesn't understand the alias
# rubocop:disable RSpec/EmptyExampleGroup
describe PfmpAmountCalculator do
  subject(:amount) { pfmp.reload.calculate_amount }

  let(:pfmp) do
    create(
      :pfmp,
      start_date: Aplypro::DEFAULT_SCHOOL_YEAR_START,
      end_date: Aplypro::DEFAULT_SCHOOL_YEAR_START >> 10,
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
          PfmpManager.new(previous).recalculate_amounts!
        end

        it_calculates "a limited amount", 2

        context "when the classe is from another year" do
          before { schooling.classe.update!(start_year: 2022) }

          it_calculates "the original amount"
        end
      end

      context "with another MEF" do
        it_calculates "the original amount"
      end
    end

    context "with that schooling" do
      before do
        previous.update!(schooling: pfmp.schooling)
        PfmpManager.new(previous).recalculate_amounts!
      end

      it_calculates "a limited amount", 2
    end
  end
end
# rubocop:enable RSpec/EmptyExampleGroup
