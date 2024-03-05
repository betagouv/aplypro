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

  context "when there is a request that isn't ready in the batch" do
    let(:payment_request) { create(:asp_payment_request, :incomplete) }

    it "raises an error" do
      expect { described_class.perform_now([payment_request]) }
        .to raise_error ASP::Errors::SendingPaymentRequestInWrongState
    end
  end
end
