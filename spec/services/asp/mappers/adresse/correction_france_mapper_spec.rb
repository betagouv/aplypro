# frozen_string_literal: true

require "rails_helper"

describe ASP::Mappers::Adresse::CorrectionFranceMapper do
  subject(:mapper) { described_class.new(payment_request) }

  let(:payment_request) { create(:asp_payment_request) }
  let(:student) { payment_request.student }
  let(:rnvp_data) do
    {
      "voieNum" => "1",
      "voieDen" => "LES MORTURES",
      "voieBis" => "BIS",
      "voieType" => "R",
      "ligne5" => "Apt 12",
      "codePostal" => "25390",
      "codeInsee" => "25288"
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
    it { expect(mapper.codeextensionvoie).to eq "BIS" }

    context "when voieBis is blank" do
      before { rnvp_data["voieBis"] = "" }

      it { expect(mapper.codeextensionvoie).to be_nil }
    end
  end

  describe "#codetypevoie" do
    it { expect(mapper.codetypevoie).to eq "R" }

    context "when voieType is blank" do
      before { rnvp_data["voieType"] = "" }

      it { expect(mapper.codetypevoie).to be_nil }
    end
  end

  describe "#cpltdistribution" do
    it { expect(mapper.cpltdistribution).to eq "Apt 12" }

    context "when ligne5 is blank" do
      before { rnvp_data["ligne5"] = "" }

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
  end
end
