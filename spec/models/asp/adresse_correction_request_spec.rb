# frozen_string_literal: true

require "rails_helper"

require "./mock/factories/asp"

RSpec.describe ASP::AdresseCorrectionRequest do
  subject(:correction_request) { create(:asp_adresse_correction_request) }

  let(:asp_payment_request) { create(:asp_payment_request, :sent) }
  let(:reason) { "mauvais code postal" }
  let(:rejects_csv) { build(:asp_reject, payment_request: asp_payment_request, reason: reason) }

  def attach_rejects_file(record, csv_content)
    record.correction_adresse_rejects_file.attach(
      io: StringIO.new(csv_content),
      filename: "rejects.csv",
      content_type: "text/csv"
    )
  end

  describe "#rejects" do
    context "when no rejects file is attached" do
      it "returns an empty hash" do
        expect(correction_request.rejects).to eq({})
      end
    end

    context "when a rejects file is attached" do
      before { attach_rejects_file(correction_request, rejects_csv) }

      it "returns a hash keyed by payment request id" do
        expect(correction_request.rejects).to include(asp_payment_request.id.to_s => reason)
      end

      it "returns the rejection reason as the value" do
        expect(correction_request.rejects.values).to eq([reason])
      end
    end
  end

  describe "#retry_rejects!" do
    before { attach_rejects_file(correction_request, rejects_csv) }

    it "enqueues a SendCorrectionAdresseJob for the rejected pfmps" do
      expect { correction_request.retry_rejects! }
        .to have_enqueued_job(SendCorrectionAdresseJob)
        .with([asp_payment_request.pfmp_id])
    end
  end
end
