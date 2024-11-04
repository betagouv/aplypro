# frozen_string_literal: true

# rubocop:disable RSpec/MultipleMemoizedHelpers
require "rails_helper"

RSpec.shared_examples "the original amount" do
  it { is_expected.to eq 3 }
end

RSpec.shared_examples "the yearly-capped amount" do
  it { is_expected.to eq 10 }
end

RSpec.shared_examples "a limited amount" do |expected_amount|
  it { is_expected.to eq expected_amount }
end

describe PfmpManager do
  subject(:manager) { described_class.new(pfmp) }

  let(:pfmp) { create(:pfmp, schooling: schooling, day_count: 2) }
  let(:mef) { create(:mef, daily_rate: 20, yearly_cap: 400) }
  let(:classe) { create(:classe, mef: mef) }
  let(:student) { create(:student, :with_all_asp_info) }
  let(:schooling) { create(:schooling, student: student, classe: classe) }

  describe "#create_new_payment_request!" do
    context "when previous payment requests are inactive" do
      let(:pfmp) { create(:asp_payment_request, :rejected).pfmp }

      it "creates a new payment request on the pfmp" do
        expect { manager.create_new_payment_request! }.to change(pfmp.payment_requests, :count).by(1)
      end
    end

    context "when previous active payment request exists" do
      let(:pfmp) { create(:pfmp, :validated).reload }

      it "raises an error" do
        expect { manager.create_new_payment_request! }.to raise_error(PfmpManager::ExistingActivePaymentRequestError)
      end
    end

    context "when there is no allowance left" do
      let(:pfmp) { create(:pfmp, schooling: schooling, day_count: 10) }

      before do
        start_date = Date.parse("#{SchoolYear.current.start_year}-09-03")

        create(
          :pfmp,
          :validated,
          start_date: start_date,
          end_date: start_date >> 4,
          day_count: 100,
          schooling: schooling
        )
      end

      it "does not create a payment" do
        expect { described_class.new(pfmp).create_new_payment_request! }.not_to change(pfmp.payment_requests, :count)
      end
    end
  end

  describe "recalculate_amounts" do
    context "when the amount is updated" do
      context "with a 'terminated' PFMP" do
        context "with an active payment request" do
          let(:pfmp) { create(:asp_payment_request, :sent).pfmp.reload }

          it "throws an error" do
            expect do
              described_class.new(pfmp).update!(day_count: 15)
            end.to raise_error(PfmpManager::PfmpNotModifiableError)
          end
        end
      end

      context "with existing other modifiable pfmps" do
        before do
          create(:pfmp, :completed, schooling: schooling, day_count: 6)
          create(:pfmp, :completed, schooling: schooling, day_count: 4)
        end

        it "recalculates the other modifiable pfmps amounts" do
          expect do
            described_class.new(pfmp).update!(day_count: 12)
          end.to change {
                   Pfmp.order(created_at: :asc).map do |p|
                     p.reload.amount
                   end
                 }.from([120, 80]).to([120, 80, 200])
        end
      end
    end
  end

  describe "#rectify_and_update_attributes!" do # rubocop:disable RSpec/MultipleMemoizedHelpers
    let(:pfmp) { create(:asp_payment_request, :paid).pfmp }
    let(:confirmed_pfmp_params) do
      { day_count: pfmp.day_count + 2, start_date: pfmp.start_date + 2.days, end_date: pfmp.end_date }
    end
    let(:confirmed_address_params) { { address_line1: "123 New St", address_city: "New City" } }

    it "rectifies the PFMP and updates attributes" do # rubocop:disable RSpec/ExampleLength
      expect do
        manager.rectify_and_update_attributes!(confirmed_pfmp_params, confirmed_address_params)
      end.to change { pfmp.reload.current_state }.from("validated").to("rectified")
                                                 .and change(pfmp, :day_count).to(confirmed_pfmp_params[:day_count])
                                                                              .and change {
                                                                                     pfmp.student.address_line1
                                                                                   }.to(confirmed_address_params[:address_line1]) # rubocop:disable Layout/LineLength
    end
  end

  describe "#calculate_amount" do # rubocop:disable RSpec/MultipleMemoizedHelpers
    subject(:amount) { described_class.new(pfmp.reload).calculate_amount }

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

    before do
      pfmp.schooling.update!(classe: classe)
    end

    context "when the PFMP doesn't have a day count" do # rubocop:disable RSpec/MultipleMemoizedHelpers
      before { described_class.new(pfmp).update!(day_count: nil) }

      it { is_expected.to be_zero }
    end

    it_behaves_like "the original amount"

    context "when the PFMP goes over the yearly cap" do # rubocop:disable RSpec/MultipleMemoizedHelpers
      before { described_class.new(pfmp).update!(day_count: 200) }

      it_behaves_like "the yearly-capped amount"
    end

    context "when there is another priced PFMP" do
      let(:previous) { create(:pfmp, :completed, day_count: 8) }

      context "with another schooling" do
        let(:schooling) { create(:schooling, :closed, student: pfmp.student) }

        before { previous.update!(schooling: schooling) }

        context "with the same MEF" do
          before { schooling.classe.update!(mef: mef) }

          it "errors when trying to recalculate" do
            expect { described_class.new(previous.reload).recalculate_amounts! }
              .to raise_error ActiveRecord::RecordInvalid
          end

          context "when the classe is from another year" do # rubocop:disable RSpec/NestedGroups
            before do
              old_school_year = create(:school_year, start_year: 2022)
              old_classe = create(:classe, school_year: old_school_year)

              schooling.update!(classe: old_classe)
            end

            it_behaves_like "the original amount"
          end
        end

        context "with another MEF" do
          it_behaves_like "the original amount"
        end
      end

      context "with that schooling" do
        it "errors" do
          expect { previous.update!(schooling: pfmp.schooling) }
            .to raise_error ActiveRecord::RecordInvalid
        end
      end
    end
  end

  describe "#other_pfmps_for_mef" do
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

    def other_pfmps_for_mef
      manager.send(:other_pfmps_for_mef)
    end

    context "when there is no other pfmp for that school year and mef" do
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

      it "returns an empty collection" do
        expect(other_pfmps_for_mef).to be_empty
      end
    end

    context "when there is another pfmp for the same mef and school year" do
      before do
        create(:pfmp,
               :validated,
               start_date: "2024-10-03",
               end_date: "2024-10-28",
               schooling: schooling,
               day_count: 3)
      end

      it "returns the other PFMP for the MEF and the current school year excluding self" do
        expect(other_pfmps_for_mef.pluck(:day_count)).to contain_exactly(3)
      end
    end
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
