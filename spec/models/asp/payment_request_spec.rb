# frozen_string_literal: true

require "rails_helper"

RSpec.describe ASP::PaymentRequest do
  describe "associations" do
    it { is_expected.to belong_to(:asp_request).optional }
  end

  describe "factory" do
    it "does not create extra payment requests" do
      expect { create(:asp_payment_request) }.to change(described_class, :count).by(1)
    end
  end

  describe 'single_active_payment_request_per_pfmp validation' do
    let(:pfmp) { create(:pfmp) }
    let(:new_payment_request) { build(:asp_payment_request, pfmp: pfmp) }

    context 'when creating a new PaymentRequest with an existing active request' do
      let!(:existing_payment_request) { create(:asp_payment_request, :incomplete, pfmp: pfmp) }

      it 'prevents creating the new request' do
        expect(new_payment_request.valid?).to be false
        expect(new_payment_request.errors[:pfmp_id]).to eq(["There can only be one active payment request per Pfmp."])
      end
    end

    context 'when creating a new PaymentRequest without an existing active request' do
      let!(:existing_payment_request) { create(:asp_payment_request, :rejected, pfmp: pfmp) }

      it 'allows creating the new request' do
        expect(new_payment_request.valid?).to be true
      end
    end
  end
end
