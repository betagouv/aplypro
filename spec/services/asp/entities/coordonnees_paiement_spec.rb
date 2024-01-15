# frozen_string_literal: true

require "rails_helper"

describe ASP::Entities::CoordonneesPaiement, type: :model do
  let(:student) { create(:rib).student }

  it_behaves_like "an ASP student mapping entity"

  describe ".to_xml" do
    subject(:document) { Nokogiri::XML(described_class.from_student(student).to_xml) }

    it "can generate some XML" do
      expect(document.to_s).not_to be_empty
    end

    specify "BIC" do
      expect(document.at("coordpaie/iban/bic")).to have_attributes(text: student.rib.bic)
    end
  end
end
