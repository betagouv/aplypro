# frozen_string_literal: true

require "rails_helper"

describe ASP::Entities::Dossier, type: :model do
  let(:payment_request) { create(:asp_payment_request, :ready) }

  before do
    mock_entity("Prestadoss")
  end

  it_behaves_like "an ASP payment mapping entity"

  it_behaves_like "an XML-fragment producer" do
    let(:entity) { described_class.from_payment_request(payment_request) }
    let(:probe) { ["dossier/numadm", payment_request.schooling.attributive_decision_number] }

    context "when the schooling has an ASP reference" do
      subject(:attributes) { document.at("dossier").attributes }

      before { payment_request.schooling.update!(asp_dossier_id: "foobar") }

      it "passes it along in IdDoss" do
        expect(attributes["idDoss"]).to have_attributes value: "foobar"
      end

      it "passes the modification false to flag" do
        expect(attributes["modification"]).to have_attributes value: "N"
      end

      %w[numadm codedispositif].each do |attr|
        it "does not reinclude the #{attr} attribute" do
          expect(document.at(attr)).to be_nil
        end
      end
    end
  end
end
