# frozen_string_literal: true

require "rails_helper"

describe ASP::Readers::IntegrationsFileReader do
  subject(:reader) { described_class.new(data) }

  let(:student) { create(:student, :with_all_asp_info) }
  let(:payment) { create(:pfmp, :validated, student: student).payments.last }
  let(:asp_payment_request) { create(:asp_payment_request, :sent, payment: payment) }

  let(:data) do
    "
Numero enregistrement;idIndDoss;idIndTiers;idDoss;numAdmDoss;idPretaDoss;numAdmPrestaDoss;idIndPrestaDoss
#{asp_payment_request.id};700056261;;700086362;ENPUPLF1POP31X20230;700085962;ENPUPLF1POP31X20230;700056261
"""
  end

  describe "payment request transition" do
    it "updates the matching payment request" do
      expect { reader.process! }.to change { asp_payment_request.reload.current_state }.from("sent").to("integrated")
    end

    it "attaches the row as JSON in the transition metadata" do
      reader.process!

      expect(asp_payment_request.last_transition.metadata["idPretaDoss"]).to eq "700085962"
    end
  end
end
