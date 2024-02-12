# frozen_string_literal: true

require "rails_helper"

describe ASP::Readers::RejectsFileReader do
  subject(:reader) { described_class.new(data) }

  let(:student) { create(:student) }

  let(:asp_payment_request) { create(:asp_payment_request, :sent) }

  let(:reason) { "failwhale" }

  let(:data) do
    "Numéro d'enregistrement;Type d'entité;Numadm;Motif rejet;idIndDoublon
#{asp_payment_request.id};;;#{reason};"
  end

  describe "payment request transition" do
    subject(:request) { asp_payment_request }

    it "fails the associated ASP payment request" do
      expect { reader.process! }.to change { request.reload.current_state }.from("sent").to("rejected")
    end

    it "attaches the row as JSON in the transition metadata" do
      reader.process!

      expect(request.last_transition.metadata["Motif rejet"]).to eq "failwhale"
    end
  end
end
