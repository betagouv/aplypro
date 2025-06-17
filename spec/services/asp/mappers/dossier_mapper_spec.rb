# frozen_string_literal: true

require "rails_helper"

describe ASP::Mappers::DossierMapper do
  subject(:mapper) { described_class.new(payment_requests) }

  let(:payment_requests) { create_list(:asp_payment_request, 3, :ready) }

  describe "#numadm" do
    it "returns the schooling's DA number" do
      expect(mapper.numadm).to eq payment_requests.first.schooling.attributive_decision_number
    end
  end

  describe "#id_dossier" do
    it "returns the schooling's asp_dossier_id" do
      expect(mapper.id_dossier).to eq payment_requests.first.schooling.asp_dossier_id
    end
  end
end
