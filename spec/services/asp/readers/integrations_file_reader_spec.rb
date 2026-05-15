# frozen_string_literal: true

require "rails_helper"

require "./mock/factories/asp"

describe ASP::Readers::IntegrationsFileReader do
  include ActiveJob::TestHelper

  subject(:reader) { described_class.new(io: data) }

  let(:asp_payment_request) { create(:asp_payment_request, :sent) }

  let(:data) { build(:asp_integration, payment_request: asp_payment_request, idPretaDoss: "foobar") }

  describe "payment request transition" do
    it "updates the matching payment request" do
      expect { reader.process! }.to change { asp_payment_request.reload.current_state }.from("sent").to("integrated")
    end

    it "attaches the row as JSON in the transition metadata" do
      reader.process!

      expect(asp_payment_request.last_transition.metadata["idPretaDoss"]).to eq "foobar"
    end
  end

  describe "correction address trigger" do
    context "when no student had a recovery payment" do
      it "does not enqueue SendCorrectionAdresseJob" do
        expect { reader.process! }.not_to have_enqueued_job(SendCorrectionAdresseJob)
      end
    end

    context "when students with recovery payments are in the file" do
      let(:recovery_pfmp_1) { create(:pfmp, :rectified_with_recovery) }
      let(:recovery_pfmp_2) { create(:pfmp, :rectified_with_recovery) }
      let(:request_1) { create(:asp_payment_request, :sent, pfmp: recovery_pfmp_1) }
      let(:request_2) { create(:asp_payment_request, :sent, pfmp: recovery_pfmp_2) }
      let(:data) do
        [
          build(:asp_integration, payment_request: request_1),
          build(:asp_integration, payment_request: request_2)
        ].join("\n")
      end

      it "enqueues exactly one SendCorrectionAdresseJob" do
        expect { reader.process! }
          .to have_enqueued_job(SendCorrectionAdresseJob).exactly(1).times
      end

      it "includes all correctable pfmp ids in the single job" do
        expect { reader.process! }
          .to have_enqueued_job(SendCorrectionAdresseJob)
          .with(contain_exactly(recovery_pfmp_1.id, recovery_pfmp_2.id))
      end
    end
  end
end
