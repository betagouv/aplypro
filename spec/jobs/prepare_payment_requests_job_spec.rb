# frozen_string_literal: true

require "rails_helper"

RSpec.describe PreparePaymentRequestsJob do
  describe "#perform" do
    let!(:sendable_request) { create(:asp_payment_request, :sendable) }
    let!(:pending_request) { create(:asp_payment_request, :pending) }

    before do
      described_class.perform_now
    end

    it "transitions a payment request to ready" do
      expect(sendable_request).to be_in_state(:ready)
    end

    it "transitions a payment request to incomplete" do
      expect(pending_request).to be_in_state(:incomplete)
    end
  end
end
