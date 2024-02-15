# frozen_string_literal: true

require "rails_helper"

RSpec.describe SendPaymentRequestsJob do
  include ActiveJob::TestHelper

  let(:student) { create(:student, :with_all_asp_info) }
  let(:pfmp) { create(:pfmp, student: student) }
  let(:payment) { create(:payment, pfmp: pfmp) }

  let(:server_double) { class_double(ASP::Server) }

  before do
    stub_const("ASP::Server", server_double)

    allow(server_double).to receive(:drop_file!)
  end

  it "doesn't pickup requests that aren't ready" do
    expect do
      perform_enqueued_jobs do
        described_class.perform_later([payment.id])
      end
    end.not_to(change { payment.payment_requests.last.current_state })
  end
end
