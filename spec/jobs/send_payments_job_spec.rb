# frozen_string_literal: true

require "rails_helper"

RSpec.describe SendPaymentsJob do
  include ActiveJob::TestHelper

  let(:student) { create(:student, :with_all_asp_info) }
  let(:pfmp) { create(:pfmp, student: student) }
  let(:payment) { create(:payment, :ready, pfmp: pfmp) }

  let(:request_double) { class_double(ASP::Request) }
  let(:double) { instance_double(ASP::Request) }

  before do
    stub_const("ASP::Request", request_double)

    allow(double).to receive(:send!)
    allow(request_double).to receive(:with_payments).and_return double
  end

  it "creates an ASP request" do
    perform_enqueued_jobs do
      described_class.perform_later([payment.id])
    end

    expect(request_double).to have_received(:with_payments).with([payment], ASP::Entities::Fichier)
  end

  it "calls send! on the request object" do
    perform_enqueued_jobs do
      described_class.perform_later([payment.id])
    end

    expect(double).to have_received(:send!).with(ASP::Server)
  end
end
