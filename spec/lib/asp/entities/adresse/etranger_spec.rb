# frozen_string_literal: true

require "rails_helper"

describe ASP::Entities::Adresse::Etranger, type: :model do
  subject(:model) { described_class.from_payment_request(request) }

  let(:request) { create(:asp_payment_request, :ready) }

  describe "validation" do
    it { is_expected.to validate_presence_of(:codepostalcedex) }
    it { is_expected.to validate_presence_of(:codecominsee) }
    it { is_expected.to validate_presence_of(:codeinseepays) }
    it { is_expected.to validate_presence_of(:codetypeadr) }
  end

  describe "fragment" do
    let(:establishment) { request.pfmp.establishment }

    before do
      establishment.update!(commune_code: "12345", postal_code: "54321")
    end

    it_behaves_like "an XML-fragment producer" do
      let(:entity) { described_class.from_payment_request(request) }
      let(:probe) { %w[codetypeadr PRINCIPALE] }

      it "uses the establishment details for the address" do
        expect(document.at("codecominsee").text).to eq establishment.commune_code
        expect(document.at("codepostalcedex").text).to eq establishment.postal_code
        expect(document.at("codeinseepays").text).to eq InseeCodes::FRANCE_INSEE_COUNTRY_CODE
      end
    end

    context "when establishment commune_code is missing" do
      before { establishment.update(commune_code: nil) }

      it "raises MissingEstablishmentCommuneCodeError" do
        expect { described_class.from_payment_request(request).to_xml(Nokogiri::XML::Builder.new) }
          .to raise_error(ActiveModel::ValidationError)
      end
    end

    context "when establishment postal_code is missing" do
      before { establishment.update(postal_code: nil) }

      it "raises MissingEstablishmentPostalCodeError" do
        expect { described_class.from_payment_request(request).to_xml(Nokogiri::XML::Builder.new) }
          .to raise_error(ActiveModel::ValidationError)
      end
    end
  end
end
