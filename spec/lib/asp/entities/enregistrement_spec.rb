# frozen_string_literal: true

require "rails_helper"

describe ASP::Entities::Enregistrement, type: :model do
  let(:payment_requests) { create_list(:asp_payment_request, 3, :ready) }

  before do
    %w[PersPhysique Adresse::France CoordPaie Dossier].each { |name| mock_entity(name) }
  end

  it_behaves_like "ASP payments mapping entity"

  it_behaves_like "an XML-fragment producer" do
    let(:entity) { described_class.from_payment_requests(payment_requests) }
    let(:probe) { ["enregistrement/individu/natureindividu", "P"] }

    describe "idIndividu" do
      subject(:attributes) { document.at("individu").attributes }

      let(:student) { payment_requests.first.student }

      context "when the student is registered with the ASP" do
        before { student.update!(asp_individu_id: "foobar") }

        it "includes the registered value in the attribute" do
          expect(attributes["idIndividu"]).to have_attributes value: "foobar"
        end

        it "includes the modification = 'O' flag" do
          expect(attributes["modification"]).to have_attributes value: "O"
        end

        %w[persphysique adressesindividu].each do |entity|
          it "does include the #{entity} entity" do
            expect(document.at(entity)).not_to be_nil
          end
        end
      end
    end

    context "when there are multiple schoolings" do
      it "includes one record per schooling" do
        expect(document.at("listedossier")).to have(3).elements
      end
    end

    context "when there are multiple payments for the same schooling" do # rubocop:disable RSpec/MultipleMemoizedHelpers
      let(:student) { create(:student) }
      let(:schooling) { create(:schooling, student: student) }
      let(:pfmps) { create_list(:pfmp, 3, :can_be_validated, schooling: schooling) }
      let(:payment_requests) { pfmps.map { |pfmp| create(:asp_payment_request, :ready, pfmp: pfmp) } }

      it "includes only one record" do
        expect(document.at("listedossier")).to have(1).elements
      end
    end
  end
end
