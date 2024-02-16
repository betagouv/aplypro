# frozen_string_literal: true

require "rails_helper"

describe ASP::Mappers::DossierMapper do
  subject(:mapper) { described_class.new(payment_request) }

  let(:payment_request) { create(:asp_payment_request, :ready) }
  let(:schooling) { payment_request.payment.schooling }

  describe "#numadm" do
    it "returns the schooling's DA number" do
      expect(mapper.numadm).to eq schooling.attributive_decision_number
    end
  end

  describe "#id_dossier" do
    it "returns the schooling's asp_dossier_id" do
      expect(mapper.id_dossier).to eq schooling.asp_dossier_id
    end
  end
end
