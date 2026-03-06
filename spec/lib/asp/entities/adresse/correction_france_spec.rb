# frozen_string_literal: true

require "rails_helper"

describe ASP::Entities::Adresse::CorrectionFrance, type: :model do
  let(:request) { create(:asp_payment_request, :ready) }
  let(:rnvp_data) do
    {
      "voieNum" => "1",
      "voieDen" => "LES MORTURES",
      "voieBis" => "",
      "voieType" => "",
      "ligne5" => "",
      "codePostal" => "25390",
      "codeInsee" => "25288"
    }
  end

  before { request.student.rnvp_data = rnvp_data }

  describe "validation" do
    subject { described_class.from_payment_request(request) }

    it { is_expected.to validate_presence_of(:libellevoie) }
    it { is_expected.to validate_presence_of(:codepostalcedex) }
    it { is_expected.to validate_presence_of(:codecominsee) }
    it { is_expected.to validate_presence_of(:codeinseepays) }
    it { is_expected.to validate_presence_of(:codetypeadr) }
  end

  it_behaves_like "an XML-fragment producer" do
    let(:entity) { described_class.from_payment_request(request) }
    let(:probe) { ["libellevoie", "LES MORTURES"] }

    it "uses RNVP data for the address fields" do
      expect(document.at("numerovoie").text).to eq "1"
      expect(document.at("codepostalcedex").text).to eq "25390"
      expect(document.at("codetypeadr").text).to eq "PRINCIPALE"
    end

    it "omits blank optional fields" do
      expect(document.at("codeextensionvoie")).to be_nil
      expect(document.at("codetypevoie")).to be_nil
      expect(document.at("cpltdistribution")).to be_nil
    end

    context "when RNVP provides optional fields" do
      let(:rnvp_data) { super().merge("voieBis" => "BIS", "voieType" => "R", "ligne5" => "Apt 12") }

      it "includes them in the output" do
        expect(document.at("codeextensionvoie").text).to eq "BIS"
        expect(document.at("codetypevoie").text).to eq "R"
        expect(document.at("cpltdistribution").text).to eq "Apt 12"
      end
    end
  end
end
