# frozen_string_literal: true

require "rails_helper"

describe ASP::Entities::CoordPaie, type: :model do
  let(:student) { create(:student, :with_rib) }
  let(:payment) { create(:payment) }

  before { payment.pfmp.update!(student: student) }

  it_behaves_like "an ASP payment mapping entity"

  it_behaves_like "an XML-fragment producer" do
    let(:entity) { described_class.from_payment(payment) }
    let(:probe) { ["coordpaie/iban/codeisopays", "FR"] }
  end
end
