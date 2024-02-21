# frozen_string_literal: true

require "rails_helper"

describe ASP::Entities::Prestadoss, type: :model do
  let(:payment_request) { create(:asp_payment_request, :ready) }
  let(:schooling) { payment_request.payment.schooling }

  before do
    mock_entity("Adresse")
    mock_entity("CoordPaie")
  end

  it_behaves_like "an ASP payment mapping entity"

  it_behaves_like "an XML-fragment producer" do
    let(:entity) { described_class.from_payment_request(payment_request) }
    let(:probe) { ["prestadoss/code", "D"] }

    it "includes an address" do
      expect(document.at("adressesprestadoss")).not_to be_nil
    end

    it "includes a rib" do
      expect(document.at("coordpaiesprestadoss")).not_to be_nil
    end

    describe "idPrestaDoss" do
      subject(:attributes) { document.at("prestadoss").attributes }

      let(:pfmp) { payment_request.payment.pfmp }

      context "when the PFMP is registered with the ASP" do
        before { pfmp.update!(asp_prestation_dossier_id: "foobar") }

        it "includes the registered value in the attribute" do
          expect(attributes["idPrestaDoss"]).to have_attributes value: "foobar"
        end

        it "includes the modification flag to false" do
          expect(attributes["modification"]).to have_attributes value: "N"
        end
      end
    end
  end
end
