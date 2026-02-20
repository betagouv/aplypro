# frozen_string_literal: true

require "rails_helper"

describe ASP::Entities::AddressFixPrestadoss, type: :model do
  let(:payment_request) { create(:asp_payment_request, :ready) }

  before do
    mock_entity("Adresse::France")
  end

  it_behaves_like "an XML-fragment producer" do
    let(:entity) { described_class.from_payment_request(payment_request) }
    let(:probe) { ["prestadoss/code", "D"] }

    it "includes an address" do
      expect(document.at("adressesprestadoss")).not_to be_nil
    end

    it "does not include a rib" do
      expect(document.at("coordpaiesprestadoss")).to be_nil
    end

    it "does not include payment elements" do
      expect(document.at("listeelementpaiement")).to be_nil
    end
  end
end
