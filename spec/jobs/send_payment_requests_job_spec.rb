# frozen_string_literal: true

require "rails_helper"

RSpec.describe SendPaymentRequestsJob do
  include ActiveJob::TestHelper

  let(:server_double) { class_double(ASP::Server) }

  before do
    stub_const("ASP::Server", server_double)

    allow(server_double).to receive(:drop_file!)

    create_list(:asp_payment_request, 5, :ready)
  end

  context "when there are no payment requests ready" do
    before { ASP::PaymentRequest.destroy_all }

    it "does not run" do
      expect { described_class.perform_now }.not_to raise_error ASP::Errors::MaxRecordsPerWeekLimitReached
    end
  end

  context "when asked to send more than the allowed amount per request" do
    before { stub_const("ASP::Request::MAX_RECORDS_PER_FILE", 3) }

    it "automatically limits it" do
      described_class.perform_now

      expect(ASP::Request.last.asp_payment_requests.count).to eq 3
    end
  end

  context "when there are already some payment requests sent" do
    before do
      allow(ASP::Request).to receive(:total_payment_requests_left).and_return 3
    end

    it "doesn't go over the limit" do
      expect { described_class.perform_now }
        .to change(ASP::PaymentRequest.in_state(:sent), :count).from(0).to(3)
    end

    context "when the limit has been completely reached" do
      before do
        allow(ASP::Request).to receive(:total_payment_requests_left).and_return 0
      end

      it "raises an error" do
        expect { described_class.perform_now }
          .to raise_error ASP::Errors::MaxRecordsPerWeekLimitReached
      end
    end
  end

  context "when the max number of uploads has been reached for the day" do
    before do
      allow(ASP::Request).to receive(:daily_requests_limit_reached?).and_return true
    end

    it "raises an error" do
      expect { described_class.perform_now }
        .to raise_error ASP::Errors::MaxRequestsPerDayLimitReached
    end
  end
end
