# frozen_string_literal: true

require "rails_helper"

describe ASP::Mappers::Adresse::CorrectionFranceMapper do
  subject(:mapper) { described_class.new(payment_request) }

  let(:payment_request) { create(:asp_payment_request) }
  let(:student) { payment_request.student }
  let(:rnvp_data) do
    {
      "id" => 0,
      "ligne2" => "",
      "ligne3" => "Apt 12",
      "ligne4" => "1 LES MORTURES",
      "ligne5" => "",
      "codePostal" => "25390",
      "localite" => "FOURNETS LUISANS",
      "codeInsee" => "25288",
      "idVoie" => "00398234",
      "idHexaposteL5L6" => "457",
      "voieNum" => "1",
      "voieBis" => "B",
      "voieBisFormeLongue" => "BIS",
      "voieType" => "RUE",
      "voieDen" => "LES MORTURES",
      "motDirecteur" => "MORTURES",
      "cedex" => "non",
      "propositions" => [],
      "codesRetour" => [{ "code" => "*000", "message" => "Adresse sans modification fondamentale." }],
      "statut" => "V",
      "litigeMineur" => false,
      "identique" => false,
      "donneesVides" => false
    }
  end

  before { student.rnvp_data = rnvp_data }

  describe "#numerovoie" do
    it { expect(mapper.numerovoie).to eq "1" }

    context "when voieNum is blank" do
      before { rnvp_data["voieNum"] = "" }

      it { expect(mapper.numerovoie).to be_nil }
    end
  end

  describe "#libellevoie" do
    it { expect(mapper.libellevoie).to eq "LES MORTURES" }
  end

  describe "#codeextensionvoie" do
    it { expect(mapper.codeextensionvoie).to eq "B" }

    context "when voieBis is blank" do
      before { rnvp_data["voieBis"] = "" }

      it { expect(mapper.codeextensionvoie).to be_nil }
    end
  end

  describe "#codetypevoie" do
    it { expect(mapper.codetypevoie).to eq "RUE" }

    context "when voieType is blank" do
      before { rnvp_data["voieType"] = "" }

      it { expect(mapper.codetypevoie).to be_nil }
    end

    context "when voieType exceeds 4 characters" do
      before { rnvp_data["voieType"] = "AVENUE" }

      it "abbreviates to fit within 4 characters without stripping vowels" do
        expect(mapper.codetypevoie).to eq "AV"
      end
    end

    context "when voieType cannot be abbreviated to 4 characters via CSV" do
      before { rnvp_data["voieType"] = "BOUCLE" }

      it "strips vowels as a last resort" do
        expect(mapper.codetypevoie).to eq "BCL"
      end
    end
  end

  describe "#cpltdistribution" do
    it { expect(mapper.cpltdistribution).to eq "Apt 12" }

    context "when ligne3 is blank" do
      before { rnvp_data["ligne3"] = "" }

      it { expect(mapper.cpltdistribution).to be_nil }
    end
  end

  describe "#codepostalcedex" do
    it { expect(mapper.codepostalcedex).to eq "25390" }
  end

  describe "#codecominsee" do
    before do
      allow(InseeExceptionCodes).to receive(:transform_insee_code).and_return :value
    end

    it { expect(mapper.codecominsee).to eq :value }

    it "passes the RNVP insee code to the transformer" do
      mapper.codecominsee
      expect(InseeExceptionCodes).to have_received(:transform_insee_code).with("25288")
    end

    context "when RNVP does not return a codeInsee" do
      before { rnvp_data["codeInsee"] = nil }

      it "falls back to the student stored insee code" do
        mapper.codecominsee
        expect(InseeExceptionCodes).to have_received(:transform_insee_code).with(student.address_city_insee_code)
      end
    end
  end
end
