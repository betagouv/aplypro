# frozen_string_literal: true

require "rails_helper"

RSpec.describe PreparePaymentsJob do
  include ActiveJob::TestHelper

  let(:payment) { instance_double(Payment) }
  let(:collection) { double }

  before do
    allow(Payment).to receive(:in_state).and_return(collection)

    allow(collection).to receive(:find_each).and_yield(payment)
  end

  context "when the payment is ready" do
    before do
      allow(payment).to receive(:mark_ready!)
    end

    it "successfully moves it" do
      perform_enqueued_jobs do
        described_class.perform_later
      end

      expect(payment).to have_received(:mark_ready!)
    end

    context "when the payment is not ready" do
      before do
        # FIXME: this isn't great but we can't really mimick the error otherwise
        error = Statesman::GuardFailedError.new(:pending, :ready, binding)

        allow(payment).to receive(:mark_ready!).and_raise(error)
        allow(payment).to receive(:block!)
      end

      it "blocks the payment" do
        perform_enqueued_jobs do
          described_class.perform_later
        end

        expect(payment).to have_received(:block!)
      end
    end
  end
end
