# frozen_string_literal: true

require "rails_helper"

describe ASP::Entities::CoordonneesPaiement, type: :model do
  let(:student) { create(:rib).student }

  it_behaves_like "an ASP student mapping entity"

  it_behaves_like "an XML-fragment producer" do
    let(:entity) { described_class.from_student(student) }
    let(:probe) { ["coordpaie/iban/bic", student.rib.bic] }
  end
end
