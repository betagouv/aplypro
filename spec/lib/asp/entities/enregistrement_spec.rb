# frozen_string_literal: true

require "rails_helper"

describe ASP::Entities::Enregistrement, type: :model do
  let(:payment_request) { create(:asp_payment_request, :ready) }

  before do
    %w[PersPhysique Adresse CoordPaie Dossier].each { |name| mock_entity(name) }
  end

  it_behaves_like "an ASP payment mapping entity"

  it_behaves_like "an XML-fragment producer" do
    let(:entity) { described_class.from_payment_request(payment_request) }
    let(:probe) { ["enregistrement/individu/natureindividu", "P"] }

    describe "idIndividu" do
      subject(:attributes) { document.at("individu").attributes }

      let(:student) { payment_request.student }

      context "when the student is registered with the ASP" do
        before { student.update!(asp_individu_id: "foobar") }

        it "includes the registered value in the attribute" do
          expect(attributes["idIndividu"]).to have_attributes value: "foobar"
        end

        it "includes the modification flag to false" do
          expect(attributes["modification"]).to have_attributes value: "O"
        end

        %w[persphysique adressesindividu coordpaiesindividu].each do |entity|
          it "does not reinclude the #{entity} entity" do
            expect(document.at(entity)).to be_nil
          end
        end
      end
    end
  end
end
