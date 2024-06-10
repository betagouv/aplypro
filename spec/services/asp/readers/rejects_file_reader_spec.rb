# frozen_string_literal: true

require "rails_helper"

require "./mock/factories/asp"

describe ASP::Readers::RejectsFileReader do
  subject(:reader) { described_class.new(io: data) }

  let(:asp_payment_request) { create(:asp_payment_request, :sent) }

  let(:reason) { "failwhale" }

  let(:data) { build(:asp_reject, payment_request: asp_payment_request, reason: "failwhale") }

  describe "payment request transition" do
    subject(:request) { asp_payment_request }

    it "fails the associated ASP payment request" do
      expect { reader.process! }.to change { request.reload.current_state }.from("sent").to("rejected")
    end

    it "attaches the row as JSON in the transition metadata" do
      reader.process!

      expect(request.last_transition.metadata.to_s).to include "failwhale"
    end
  end

  context "when the original ISO-8859-1 encoding is used by the ASP" do
    let(:data) { File.read("spec/lib/asp/readers/rejets_mock.csv") }

    before do
      # Ici, on vérifie que le format d'encodage soit le bon
      # L'ID numéro 43 est donc purement arbitraire (Donnée dans le mock)
      if ASP::PaymentRequest.where(id: 43).blank?
        p_r = create(:asp_payment_request, :sendable)
        p_r.update(id: 43)
        p_r.mark_ready!

        create(:asp_request, asp_payment_requests: [p_r])
        p_r.mark_sent!
      end
    end

    it "can still process the file" do
      # We check that no 'Encoding::CompatibilityError' is raised
      expect { reader.process! }.not_to raise_error
    end
  end
end
