# frozen_string_literal: true

require "rails_helper"
require "./script/payments_fixer"

RSpec.describe PaymentsFixer do
  subject(:fix) { described_class.fix_all! }

  before do
    create_list(:pfmp, 2, :validated)
  end

  it "goes well" do
    expect { fix }.not_to raise_error
  end

  context "when there is an exta payment for a pfmp" do
    before do
      create(:payment, pfmp: Pfmp.last)
    end

    it "deletes the extra payments" do
      expect { fix }.to change(Payment, :count).by(-1)
    end
  end

  context "when there is a payment with incorrect amount" do
    let(:day_count) { 4 }
    let(:pfmp) { create(:pfmp, :validated, day_count: day_count) }
    let(:payment) { pfmp.payments.first }

    before do
      payment.update(amount: 27)
    end

    it "corrects the payment amount" do
      expect { fix }.to change { payment.reload.amount }.to 4
    end

    context "when it goes over the yearly cap" do
      let(:day_count) { 400 }

      it "corrects the payment amount, limited by the yearly cap" do
        expect { fix }.to change { payment.reload.amount }.to 100
      end
    end
  end
end
