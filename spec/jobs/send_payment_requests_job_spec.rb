# frozen_string_literal: true

require "rails_helper"

RSpec.describe SendPaymentRequestsJob do
  include ActiveJob::TestHelper

  let(:asp_payment_request) { create(:asp_payment_request, :ready) }

  let(:server_double) { class_double(ASP::Server) }

  before do
    stub_const("ASP::Server", server_double)

    allow(server_double).to receive(:drop_file!)
  end

  context "when there are already some payment requests sent" do
    let(:payment_requests) { create_list(:asp_payment_request, 10, :ready) }

    before do
      allow(ASP::Request).to receive(:total_requests_left).and_return 3
    end

    it "doesn't go over the limit" do
      expect { described_class.perform_now(payment_requests) }
        .to change(ASP::PaymentRequest.in_state(:sent), :count).from(0).to(3)
    end

    context "when the limit has been completely reached" do
      before do
        allow(ASP::Request).to receive(:total_requests_left).and_return 0
      end

      it "raises an error" do
        expect { described_class.perform_now(payment_requests) }
          .to raise_error ASP::Errors::MaxRecordsPerWeekLimitReached
      end
    end
  end

  context "when the max number of uploads has been reached for the day" do
    before do
      allow(ASP::Request).to receive(:daily_requests_limit_reached?).and_return true
    end

    it "raises an error" do
      expect { described_class.perform_now([asp_payment_request]) }
        .to raise_error ASP::Errors::MaxRequestsPerDayLimitReached
    end
  end

  context "when there is a request in the wrong state" do
    let(:payment_request) { create(:asp_payment_request, :sent) }

    it "raises an error" do
      expect { described_class.perform_now([payment_request]) }
        .to raise_error ASP::Errors::SendingPaymentRequestInWrongState
    end

    it "does not persist the request" do
      suppress(ASP::Errors::SendingPaymentRequestInWrongState) do
        expect { described_class.perform_now([payment_request]) }.not_to change(ASP::Request, :count)
      end
    end
  end
end
