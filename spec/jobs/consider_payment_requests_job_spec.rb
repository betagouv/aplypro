# frozen_string_literal: true

require "rails_helper"

RSpec.describe ConsiderPaymentRequestsJob do
  include ActiveJob::TestHelper

  let(:payment_requests) { create_list(:asp_payment_request, 3) }

  before do
    allow(ASP::PaymentRequest).to receive(:to_consider).and_return(payment_requests)
  end

  it "passes the upto argument to the scope" do
    described_class.perform_now

    expect(ASP::PaymentRequest).to have_received(:to_consider).once
  end

  it "queues all the payment requests in the to_consider scope" do
    expect { described_class.perform_now }
      .to have_enqueued_job(PreparePaymentRequestJob).exactly(3).times
  end

  context "when there is a rectified PFMP" do
    let(:old_rectified_pfmp) { create(:pfmp, :rectified) }

    before { payment_requests << old_rectified_pfmp.latest_payment_request }

    it "queues only the correct payment request into SendCorrectionAdresseJob" do
      expect { described_class.perform_now }
        .to have_enqueued_job(SendCorrectionAdresseJob).with([old_rectified_pfmp.id]).exactly(1).times
    end
  end
end
