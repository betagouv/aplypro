# frozen_string_literal: true

require "rails_helper"

RSpec.describe ASP::PaymentRequest do
  subject { create(:asp_payment_request) }

  describe "associations" do
    it { is_expected.to belong_to(:asp_request).optional }
    it { is_expected.to belong_to(:asp_payment_return).optional }
  end

  describe "scopes" do
    describe "latest_per_pfmp" do
      let(:pfmp) { create(:pfmp) }
      let(:payment_requests) { create_list(:asp_payment_request, 3, :rejected) }

      before do
        payment_requests.each_with_index do |request, i|
          request.update!(pfmp: pfmp, created_at: request.created_at + (i * 10.minutes))
        end
      end

      it "only returns the last payment requests for a given pfmp based on created_at" do
        expect(pfmp.payment_requests.latest_per_pfmp.to_a).to eq [payment_requests.last]
      end
    end
  end

  describe "active?" do
    subject { create(:asp_payment_request, state) }

    context "when it is rejected" do
      let(:state) { :rejected }

      it { is_expected.not_to be_active }
    end

    context "when it is unpaid" do
      let(:state) { :unpaid }

      it { is_expected.not_to be_active }
    end

    context "when it is sent" do
      let(:state) { :sent }

      it { is_expected.to be_active }
    end
  end

  describe "factories" do
    ASP::PaymentRequestStateMachine.states.each do |state|
      it "has a valid '#{state}' factory" do
        expect(create(:asp_payment_request, state)).to be_valid
      end
    end

    # NOTE: a previous version of the factory was creating 2 records on each call
    # The problem was solved using initialize_with which has different side-effects
    it "does not create extra payment requests" do
      expect { create(:asp_payment_request) }.to change(described_class, :count).by(1)
    end
  end

  describe "single_active_payment_request_per_pfmp validation" do
    let(:new_payment_request) { described_class.new(pfmp: existing_payment_request.pfmp) }

    context "when creating a new payment request with an existing active request" do
      let(:existing_payment_request) { create(:asp_payment_request, :sent) }

      it "prevents creating the new request" do
        new_payment_request.validate
        expect(new_payment_request.errors[:base]).to eq(["There can only be one active payment request per Pfmp."])
      end
    end

    context "when creating a new payment request without an existing active request" do
      let(:existing_payment_request) { create(:asp_payment_request, :rejected) }

      it "allows creating the new request" do
        expect(new_payment_request).to be_valid
      end
    end
  end

  describe "rejection_reason" do
    let(:payment_request) { create(:asp_payment_request, :rejected, reason: "failwhale") }

    it "finds the right metadata" do
      expect(payment_request.rejection_reason).to eq "failwhale"
    end
  end

  describe "unpaid reason" do
    let(:payment_request) { create(:asp_payment_request, :unpaid, reason: "failwhale") }

    it "finds the right metadata" do
      expect(payment_request.unpaid_reason).to eq "failwhale"
    end
  end
end
