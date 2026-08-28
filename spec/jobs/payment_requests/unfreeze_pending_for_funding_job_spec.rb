# frozen_string_literal: true

require "rails_helper"

RSpec.describe PaymentRequests::UnfreezePendingForFundingJob do
  let!(:funding_request) do
    create(:asp_payment_request, :sendable).tap do |request|
      request.mark_pending!(pending_reason: ASP::PaymentRequest::FUNDING_ISSUE)
    end
  end

  it "marks payment requests pending for funding as ready" do
    expect { described_class.perform_now }
      .to change { funding_request.reload.current_state }.from("pending").to("ready")
  end

  it "logs how many payment requests were unfrozen" do
    allow(Rails.logger).to receive(:info)

    described_class.perform_now

    expect(Rails.logger).to have_received(:info)
      .with("Unfroze 1 pending payment request for funding")
  end

  it "filters funding issues in the database" do
    requests = described_class.new.send(:pending_requests_for_funding, nil)

    expect(requests).to be_an(ActiveRecord::Relation)
    expect(requests).to contain_exactly(funding_request)
  end

  context "when a pending payment request is not blocked for funding" do
    let!(:other_pending_request) do
      create(:asp_payment_request, :sendable).tap do |request|
        request.mark_pending!(pending_reason: "Another reason")
      end
    end

    it "leaves it pending" do
      described_class.perform_now

      expect(other_pending_request).to be_in_state(:pending)
    end
  end

  context "when unfreezing a payment request fails" do
    let!(:other_funding_request) do
      create(:asp_payment_request, :sendable).tap do |request|
        request.mark_pending!(pending_reason: ASP::PaymentRequest::FUNDING_ISSUE)
      end
    end
    let(:job) { described_class.new }
    let(:scope) do
      instance_double(ActiveRecord::Relation, find_each: [funding_request, other_funding_request].each)
    end

    before do
      allow(job).to receive(:pending_requests_for_funding)
        .and_return(scope)
      allow(other_funding_request).to receive(:mark_ready!).and_raise("Could not unfreeze payment request")
      allow(Rails.logger).to receive(:info)
    end

    it "rolls back all transitions and does not log a success" do
      expect { job.perform_now }.to raise_error("Could not unfreeze payment request")
      expect(funding_request.reload).to be_in_state(:pending)
      expect(other_funding_request.reload).to be_in_state(:pending)
      expect(Rails.logger).not_to have_received(:info).with(/Unfroze/)
    end
  end

  context "with a ministry" do
    let!(:masa_request) do
      create(:asp_payment_request, :sendable).tap do |request|
        request.pfmp.classe.update!(mef: create(:mef, ministry: Mef.ministries[:masa]))
        request.mark_pending!(pending_reason: ASP::PaymentRequest::FUNDING_ISSUE)
      end
    end

    it "only unfreezes payment requests for that ministry" do
      described_class.perform_now("masa")

      expect(masa_request).to be_in_state(:ready)
      expect(funding_request).to be_in_state(:pending)
    end

    it "unfreezes every ministry when none is given" do
      described_class.perform_now

      expect(masa_request).to be_in_state(:ready)
      expect(funding_request).to be_in_state(:ready)
    end
  end
end
