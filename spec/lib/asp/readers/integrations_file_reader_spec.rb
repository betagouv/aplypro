# frozen_string_literal: true

require "rails_helper"

describe ASP::Readers::IntegrationsFileReader do
  subject(:reader) { described_class.new(data) }

  let(:student) { create(:student) }
  let(:asp_payment_request) { create(:asp_payment_request, :sent) }

  let(:data) do
    "
Numero enregistrement;idIndDoss;idIndTiers;idDoss;numAdmDoss;idPretaDoss;numAdmPrestaDoss;idIndPrestaDoss
#{asp_payment_request.id};700056261;;700086362;ENPUPLF1POP31X20230;700085962;ENPUPLF1POP31X20230;700056261
"""
  end

  xit "updates an existing individual request" do
    expect { reader.process! }.to change { student.reload.asp_individual_reference }.from(nil).to("700056261")
  end

  describe "payment request transition" do
    subject(:request) { asp_payment_request }

    it "fails the associated ASP payment request" do
      expect { reader.process! }.to change { request.reload.current_state }.from("sent").to("integrated")
    end

    it "attaches the row as JSON in the transition metadata" do
      reader.process!

      expect(request.last_transition.metadata["idPretaDoss"]).to eq "700085962"
    end
  end
end
