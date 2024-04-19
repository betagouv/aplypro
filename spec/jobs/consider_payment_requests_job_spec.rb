# frozen_string_literal: true

require "rails_helper"

RSpec.describe ConsiderPaymentRequestsJob do
  include ActiveJob::TestHelper

  let(:payment_requests) { create_list(:asp_payment_request, 3) }

  before do
    allow(ASP::PaymentRequest).to receive(:to_consider).and_return(payment_requests)
  end

  it "passes the upto argument to the scope" do
    described_class.perform_now(:date)

    expect(ASP::PaymentRequest).to have_received(:to_consider).once.with(:date)
  end

  it "queues all the payment requests in the to_consider scope" do
    expect { described_class.perform_now(1.year.from_now) }
      .to have_enqueued_job(PreparePaymentRequestJob).exactly(3).times
  end
end
