# frozen_string_literal: true

require "rails_helper"

describe ASP::Entities::Adresse::France, type: :model do
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
    let(:probe) { ["codecominsee", student.address_city_insee_code] }

    it "uses the address details of the student" do # rubocop:disable RSpec/MultipleExpectations
      expect(document.at("codepostalcedex").text).to eq student.address_postal_code
      expect(document.at("codeinseepays").text).to eq InseeCodes::FRANCE_INSEE_COUNTRY_CODE
      expect(document.at("codetypeadr").text).to eq "PRINCIPALE"
    end
  end
end
