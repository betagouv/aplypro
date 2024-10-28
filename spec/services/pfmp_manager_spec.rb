# frozen_string_literal: true

require "rails_helper"

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
            expect { pfmp.update!(day_count: 15) }.to raise_error(PfmpManager::PfmpNotModifiableError)
          end
        end
      end

      context "with existing follow up modifiable pfmps" do
        before do
          create(:pfmp, :completed, schooling: schooling, day_count: 6, created_at: pfmp.created_at + 2.days)
          create(:pfmp, :completed, schooling: schooling, day_count: 4, created_at: pfmp.created_at + 3.days)
        end

        it "recalculates the follow up modifiable pfmps amounts and caps the last one" do
          expect do
            pfmp.update!(day_count: pfmp.day_count + 11)
          end.to change {
                   [pfmp.amount] + pfmp.rebalancable_pfmps.pluck(:amount)
                 }.from([40, 120, 80]).to([260, 120, 20])
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
end
