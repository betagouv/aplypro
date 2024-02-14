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
  end
end
