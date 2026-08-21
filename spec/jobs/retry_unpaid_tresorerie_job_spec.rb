# frozen_string_literal: true

require "rails_helper"

RSpec.describe RetryUnpaidTresorerieJob do
  let!(:tresorerie_request) { create(:asp_payment_request, :unpaid, code_motif: "TR2") }

  it "retries the payment requests unpaid because of insufficient trésorerie" do
    expect { described_class.perform_now }.to change(tresorerie_request.pfmp.payment_requests, :count).by(1)
    expect(tresorerie_request.pfmp.reload.latest_payment_request).to be_in_state(:ready)
  end

  it "logs how many payment requests were retried" do
    allow(Rails.logger).to receive(:info)

    described_class.perform_now

    expect(Rails.logger).to have_received(:info).with("Retried 1 unpaid trésorerie payment requests")
  end

  context "when the payment request is unpaid for another reason" do
    let!(:tresorerie_request) { create(:asp_payment_request, :unpaid, code_motif: "RJT") }

    it "leaves it alone" do
      expect { described_class.perform_now }.not_to change(tresorerie_request.pfmp.payment_requests, :count)
    end
  end

  context "when the payment request went unpaid before the retry window" do
    before do
      tresorerie_request.last_transition.update!(created_at: (described_class::RETRY_WINDOW + 1.day).ago)
    end

    it "leaves it alone" do
      expect { described_class.perform_now }.not_to change(tresorerie_request.pfmp.payment_requests, :count)
    end
  end

  context "with a ministry" do
    let!(:masa_request) { create(:asp_payment_request, :unpaid, code_motif: "TR2") }

    before { masa_request.pfmp.classe.update!(mef: create(:mef, ministry: Mef.ministries[:masa])) }

    it "only retries the payment requests of that ministry" do
      expect { described_class.perform_now("masa") }.to change(masa_request.pfmp.payment_requests, :count).by(1)
      expect(tresorerie_request.pfmp.reload.latest_payment_request).to eq tresorerie_request
    end

    it "retries every ministry when none is given" do
      described_class.perform_now

      expect(masa_request.pfmp.payment_requests.count).to eq 2
      expect(tresorerie_request.pfmp.payment_requests.count).to eq 2
    end
  end
end
