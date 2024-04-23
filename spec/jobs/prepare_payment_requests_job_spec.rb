# frozen_string_literal: true

require "rails_helper"

RSpec.describe PreparePaymentRequestsJob do
  include ActiveJob::TestHelper

  let(:payment_request) { instance_double(ASP::PaymentRequest) }
  let(:collection) { double }

  before do
    allow(ASP::PaymentRequest).to receive(:in_state).and_return(collection)

    allow(collection).to receive(:find_each).and_yield(payment_request)
  end

  context "when the payment_request is ready" do
    before do
      allow(payment_request).to receive(:can_transition_to?).with(:ready).and_return(true)
      allow(payment_request).to receive(:mark_ready!)
    end

    it "successfully moves it" do
      perform_enqueued_jobs do
        described_class.perform_later
      end

      expect(payment_request).to have_received(:mark_ready!)
    end

    context "when the payment_request is not ready" do
      before do
        # FIXME: this isn't great but we can't really mimick the error otherwise
        Statesman::GuardFailedError.new(:pending, :ready, binding)

        allow(payment_request).to receive(:can_transition_to?).with(:ready).and_return(false)
        allow(payment_request).to receive(:mark_incomplete!)
      end

      it "blocks the payment_request" do
        perform_enqueued_jobs do
          described_class.perform_later
        end
        expect(payment_request).to have_received(:mark_incomplete!)
      end
    end
  end
end
