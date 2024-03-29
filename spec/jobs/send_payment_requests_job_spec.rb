# frozen_string_literal: true

require "rails_helper"

RSpec.describe SendPaymentRequestsJob do
  include ActiveJob::TestHelper

  let(:asp_payment_request) { create(:payment_request, :ready) }

  let(:server_double) { class_double(ASP::Server) }

  before do
    stub_const("ASP::Server", server_double)

    allow(server_double).to receive(:drop_file!)
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
