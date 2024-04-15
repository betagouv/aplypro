# frozen_string_literal: true

require "rails_helper"

describe PfmpManager do
  subject(:manager) { described_class.new(pfmp) }

  let(:pfmp) { create(:pfmp, schooling: schooling)}
  let(:mef) { create(:mef) }
  let(:classe) { create(:classe, mef: mef) }
  let(:student) { create(:student, :with_all_asp_info) }
  let(:schooling) { create(:schooling, student: student, classe: classe) }

  describe "#reset_payment_request!" do
    context "when previous payment requests are inactive" do
      let(:pfmp) { create(:asp_payment_request, :rejected).pfmp }

      it "creates a new payment request on the pfmp" do
        expect { manager.reset_payment_request! }.to change(pfmp.payment_requests, :count).by(1)
      end
    end

    context "when previous active payment request exists" do
      let(:pfmp) { create(:asp_payment_request, :integrated).pfmp }

      it "raises an error" do
        expect { manager.reset_payment_request! }.to raise_error(PfmpManager::PreviousActivePaymentRequestError)
      end
    end

    context "when there is no allowance left" do
      let(:pfmp) { create(:pfmp, schooling: schooling, day_count: 10) }

      before do
        create(
          :pfmp,
          :validated,
          start_date: Aplypro::SCHOOL_YEAR_START,
          end_date: Aplypro::SCHOOL_YEAR_START >> 4,
          day_count: 100,
          schooling: schooling
        )
      end

      it "does not create a payment" do
        expect { PfmpManager.new(pfmp).reset_payment_request! }.not_to change(pfmp.payment_requests, :count)
      end
    end
  end

  describe "recalculate_amounts" do
    context "when the amount is updated" do
      context "with a 'terminated' PFMP" do
        context "with an active payment request" do
          let(:pfmp) { create(:asp_payment_request, :sent).pfmp }

          it "throws an error" do
            expect { pfmp.update!(day_count: 15) }.to raise_error(PfmpManager::PfmpNotModifiableError)
          end
        end
      end

      context "with existing follow up modifiable pfmps" do
        let(:existing_pfmp) { create(:pfmp, :completed, schooling: schooling, day_count: 2) }
        let(:mef) { create(:mef, daily_rate: 20, yearly_cap: 400) }

        before do
          create(:pfmp, :completed, schooling: schooling, day_count: 6, created_at: existing_pfmp.created_at + 2.days)
          create(:pfmp, :completed, schooling: schooling, day_count: 4, created_at: existing_pfmp.created_at + 3.days)
          existing_pfmp.update!(day_count: existing_pfmp.day_count + 10)
        end

        it "recalculates the follow up modifiable pfmps amounts" do
          expect(existing_pfmp.following_modifiable_pfmps.pluck(:amount)).to eq [120, 40]
        end
      end
    end
  end
end
