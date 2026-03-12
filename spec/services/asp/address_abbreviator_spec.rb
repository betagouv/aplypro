# frozen_string_literal: true

require "rails_helper"

RSpec.describe ASP::AddressAbbreviator do
  describe ".abbreviate" do
    context "when text is nil" do
      it "returns nil" do
        expect(described_class.abbreviate_address_line(nil, max_length: 28)).to be_nil
      end
    end

    context "when text is blank" do
      it "returns nil" do
        expect(described_class.abbreviate_address_line("", max_length: 28)).to be_nil
      end
    end

    context "when text is within the max_length" do
      it "returns the original text without abbreviating" do
        expect(described_class.abbreviate_address_line("12 Boulevard Victor", max_length: 28))
          .to eq("12 Boulevard Victor")
      end

      it "does not abbreviate even if abbreviatable words are present" do
        expect(described_class.abbreviate_road_type("Résidence A", max_length: 28)).to eq("Résidence A")
      end
    end

    context "when text exceeds max_length and contains abbreviatable words" do
      it "abbreviates Boulevard to BV" do
        expect(described_class.abbreviate_road_type("12 Boulevard de la République", max_length: 28))
          .to eq("12 BD DE LA REPUBLIQUE")
      end

      it "abbreviates Appartement to APP" do
        expect(described_class.abbreviate_address_line("Appartement 5 de la rue longue", max_length: 28))
          .to eq("APP 5 DE LA RUE LONGUE")
      end

      it "abbreviates Place to PL" do
        expect(described_class.abbreviate_road_type("Place de la Victoire Extraordinaire", max_length: 28))
          .to eq("PL DE LA VICTOIRE EXTRAORDINAIRE")
      end

      it "abbreviates Chemin to CHEM" do
        expect(described_class.abbreviate_road_type("Chemin des Écoliers et des Aventuriers", max_length: 28))
          .to eq("CHEM DES ECOLIERS ET DES AVENTURIERS")
      end

      it "abbreviates Résidence to RESI" do
        expect(described_class.abbreviate_road_type("Résidence Les Oliviers de la Provence", max_length: 28))
          .to eq("RESI LES OLIVIERS DE LA PROVENCE")
      end

      it "abbreviates Impasse, Grande Rue and Moulin" do
        expect(described_class.abbreviate_road_type("Impasse du Moulin de la Grande Rue", max_length: 28))
          .to eq("IMP DU MOUL DE LA GRAN")
      end

      it "only abbreviates Grande, and not Impasse, Moulin and Rue" do
        expect(described_class.abbreviate_address_line("Impasse du Moulin de la Grande Rue", max_length: 28))
          .to eq("IMPASSE DU MOULIN DE LA GDE RUE")
      end

      it "abbreviates multiple words in the same string" do
        expect(described_class.abbreviate_road_type("Résidence Le Parc, Boulevard Victor Hugo, Appartement 12",
                                                    max_length: 28))
          .to eq("RESI LE PARC BD VICTOR HUGO APPARTEMENT 12")
      end

      it "is case insensitive" do
        expect(described_class.abbreviate_road_type("boulevard de la république française", max_length: 28))
          .to eq("BD DE LA REPUBLIQUE FRANCAISE")
        expect(described_class.abbreviate_road_type("BOULEVARD de la république française", max_length: 28))
          .to eq("BD DE LA REPUBLIQUE FRANCAISE")
      end

      it "only matches whole words" do
        expect(described_class.abbreviate_road_type("Boulevardier de la rue principale", max_length: 28))
          .to eq("BOULEVARDIER DE LA RUE PRINCIPALE")
      end
    end

    context "when abbreviated text is still too long" do
      it "returns the abbreviated text without truncating" do
        result = described_class.abbreviate_road_type("12 Boulevard de la République Française Extraordinaire",
                                                      max_length: 28)
        expect(result).to eq("12 BD DE LA REPUBLIQUE FRANCAISE EXTRAORDINAIRE")
        expect(result.length).to be > 28
      end
    end
  end
end
