# frozen_string_literal: true

require "rails_helper"

describe ASP::Entities::Dossier, type: :model do
  let(:payment_requests) { create_list(:asp_payment_request, 3, :ready) }

  before do
    mock_entity("Prestadoss")
  end

  it_behaves_like "ASP payments mapping entity"

  # When the mef's ministry is MER, we have one less character than for ENPU, ENPR or ARMEE
  it { is_expected.to validate_length_of(:numadm) }

  it_behaves_like "an XML-fragment producer" do
    let(:entity) { described_class.from_payment_requests(payment_requests) }
    let(:probe) { ["dossier/numadm", payment_requests.first.schooling.attributive_decision_number] }

    context "when the schooling has an ASP reference" do
      subject(:attributes) { document.at("dossier").attributes }

      before { payment_requests.first.schooling.update!(asp_dossier_id: "foobar") }

      it "passes it along in IdDoss" do
        expect(attributes["idDoss"]).to have_attributes value: "foobar"
      end

      it "passes the modification = 'N' (Non)" do
        expect(attributes["modification"]).to have_attributes value: "N"
      end
    end
  end
end
