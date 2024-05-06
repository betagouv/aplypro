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
      let(:pfmp) { create(:asp_payment_request, :integrated).pfmp }

      it "raises an error" do
        expect { manager.create_new_payment_request! }.to raise_error(PfmpManager::ExistingActivePaymentRequestError)
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
        expect { described_class.new(pfmp).create_new_payment_request! }.not_to change(pfmp.payment_requests, :count)
      end
    end
  end

  describe '#retry_incomplete_payment_request!' do
    let(:payment_request) { create(:asp_payment_request, :incomplete) }
    let(:pfmp) { payment_request.pfmp }

    context 'when last payment request is not incomplete' do
      let(:payment_request) { create(:asp_payment_request, :unpaid)}

      it 'raises an error' do
        expect { manager.retry_incomplete_payment_request! }
          .to raise_error(PfmpManager::PaymentRequestNotIncompleteError)
      end
    end

    context 'when last payment request is incomplete' do
      it 'returns false if the payment_request stays in incomplete state' do
        expect(manager.retry_incomplete_payment_request!).to be false
      end

      it 'returns true if the payment_request moves out of incomplete state' do
        payment_request.student.update!(address_country_code: "99100")

        expect(manager.retry_incomplete_payment_request!).to be true
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
        before do
          create(:pfmp, :completed, schooling: schooling, day_count: 6, created_at: pfmp.created_at + 2.days)
          create(:pfmp, :completed, schooling: schooling, day_count: 4, created_at: pfmp.created_at + 3.days)
        end

        it "recalculates the follow up modifiable pfmps amounts and caps the last one" do
          expect do
            pfmp.update!(day_count: pfmp.day_count + 11)
          end.to change {
                   [pfmp.amount] + pfmp.following_modifiable_pfmps.pluck(:amount)
                 }.from([40, 120, 80]).to([260, 120, 20])
        end
      end
    end
  end
end
