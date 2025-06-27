# frozen_string_literal: true

require "rails_helper"

describe ASP::Entities::CoordPaie, type: :model do
  subject(:model) { described_class.from_payment_request(payment_request) }

  let(:payment_request) { create(:asp_payment_request, :ready) }

  it_behaves_like "a limited string attribute", attribute: :intitdest, length: 32

  it_behaves_like "an ASP payment mapping entity"

  it_behaves_like "an XML-fragment producer" do
    let(:entity) { described_class.from_payment_request(payment_request) }
    let(:probe) { ["coordpaie/iban/codeisopays", "FR"] }
  end
end
