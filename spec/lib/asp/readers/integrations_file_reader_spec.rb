# frozen_string_literal: true

require "rails_helper"

require "./mock/factories/asp"

describe ASP::Readers::IntegrationsFileReader do
  subject(:reader) { described_class.new(data) }

  let(:student) { create(:student, :with_all_asp_info) }
  let(:payment) { create(:pfmp, :validated, student: student).payments.last }
  let(:asp_payment_request) { create(:asp_payment_request, :sent, payment: payment) }

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
end
