# frozen_string_literal: true

require "rails_helper"

describe ASP::Entities::Adresse, type: :model do
  subject(:model) { described_class.from_payment_request(request) }

  let(:request) { create(:asp_payment_request, :ready) }
  let(:student) { create(:student, :with_all_asp_info, :with_french_address) }

  before do
    request.pfmp.update!(student: student)
    request.reload
  end

  describe "validation" do
    it { is_expected.to validate_presence_of(:codepostalcedex) }
    it { is_expected.to validate_presence_of(:codecominsee) }
    it { is_expected.to validate_presence_of(:codeinseepays) }
    it { is_expected.to validate_presence_of(:codetypeadr) }
  end

  it_behaves_like "an XML-fragment producer" do
    let(:entity) { described_class.from_payment_request(request) }
    let(:probe) { ["adresse/codecominsee", student.address_city_insee_code] }
  end

  describe ".from_payment_request" do
    context "when the student lives abroad" do
      let(:student) { create(:student, :with_all_asp_info, :with_foreign_address) }
      let(:establishment) { request.pfmp.establishment }

      before do
        establishment.update(commune_code: "12345", postal_code: "54321")
      end

      it "creates an Adresse instance with establishment details" do # rubocop:disable RSpec/ExampleLength
        adresse = described_class.from_payment_request(request)
        expect(adresse).to have_attributes(
          codetypeadr: ASP::Mappers::AdresseMapper::ABROAD_ADDRESS_TYPE,
          codecominsee: establishment.commune_code,
          codepostalcedex: establishment.postal_code,
          codeinseepays: InseeCodes::FRANCE_INSEE_COUNTRY_CODE
        )
      end

      context "when establishment commune_code is missing" do
        before { establishment.update(commune_code: nil) }

        it "raises MissingEstablishmentCommuneCodeError" do
          expect { described_class.from_payment_request(request) }
            .to raise_error(ASP::Errors::MissingEstablishmentCommuneCodeError)
        end
      end

      context "when establishment postal_code is missing" do
        before { establishment.update(postal_code: nil) }

        it "raises MissingEstablishmentPostalCodeError" do
          expect { described_class.from_payment_request(request) }
            .to raise_error(ASP::Errors::MissingEstablishmentPostalCodeError)
        end
      end
    end
  end
end
