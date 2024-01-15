# frozen_string_literal: true

require "rails_helper"

describe ASP::Entities::Adresse, type: :model do
  describe ".from_student" do
    subject(:model) { described_class.from_student(student) }

    let(:student) { create(:student, :with_french_address) }

    describe "validation" do
      context "when the address is in France" do
        it { is_expected.to validate_presence_of(:codepostalcedex) }
        it { is_expected.to validate_presence_of(:codecominsee) }
      end

      context "when the address is abroad" do
        let(:student) { create(:student, :with_foreign_address) }

        it { is_expected.to validate_presence_of(:localiteetranger) }
        it { is_expected.to validate_presence_of(:bureaudistribetranger) }
      end
    end

    describe "to_xml" do
      subject(:document) { Nokogiri::XML(described_class.from_student(student).to_xml) }

      it "can generate some XML" do
        expect(document.to_s).not_to be_empty
      end

      specify "INSEE postal code" do
        expect(document.at("adresse/codecominsee")).to have_attributes(text: student.address_city_insee_code)
      end
    end
  end
end
