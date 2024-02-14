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
  end
end
