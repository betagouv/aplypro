# frozen_string_literal: true

require "rails_helper"

describe ASP::Entities::Adresse::CorrectionFrance, type: :model do
  let(:request) { create(:asp_payment_request, :ready) }
  let(:rnvp_data) do
    {
      "id" => 0,
      "ligne2" => "",
      "ligne3" => "",
      "ligne4" => "1 LES MORTURES",
      "ligne5" => "",
      "codePostal" => "25390",
      "localite" => "FOURNETS LUISANS",
      "codeInsee" => "25288",
      "idVoie" => "00398234",
      "idHexaposteL5L6" => "457",
      "voieNum" => "1",
      "voieBis" => "",
      "voieBisFormeLongue" => "",
      "voieType" => "",
      "voieDen" => "LES MORTURES",
      "motDirecteur" => "MORTURES",
      "cedex" => "non",
      "propositions" => [],
      "codesRetour" => [{ "code" => "*004", "message" => "L'orthographe de la localité a été modifiée." }],
      "statut" => "V",
      "litigeMineur" => false,
      "identique" => false,
      "donneesVides" => false
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
    it { is_expected.to validate_length_of(:libellevoie).is_at_most(28) }
    it { is_expected.to validate_length_of(:cpltdistribution).is_at_most(38) }
    it { is_expected.to validate_length_of(:codeextensionvoie).is_at_most(1) }
    it { is_expected.to validate_length_of(:codetypevoie).is_at_most(4) }
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
      let(:rnvp_data) { super().merge("voieBis" => "Bis", "voieType" => "RUE", "ligne3" => "Apt 12") }

      it "includes them in the output" do
        expect(document.at("codeextensionvoie").text).to eq "B"
        expect(document.at("codetypevoie").text).to eq "RUE"
        expect(document.at("cpltdistribution").text).to eq "Apt 12"
      end
    end

    context "when RNVP provides data not processed by ASP" do
      let(:rnvp_data) { super().merge("voieBis" => "B", "voieType" => "RUE", "ligne3" => "Apt 12") }

      it "maps them in the appropriate output" do
        expect(document.at("codeextensionvoie")).to be_nil
        expect(document.at("cpltdistribution").text).to eq "B Apt 12"
      end
    end
  end
end
