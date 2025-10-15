# frozen_string_literal: true

require "rails_helper"

RSpec.describe ASP::AddressAbbreviator do
  describe ".abbreviate" do
    context "when text is nil" do
      it "returns nil" do
        expect(described_class.abbreviate(nil, max_length: 28)).to be_nil
      end
    end

    context "when text is blank" do
      it "returns nil" do
        expect(described_class.abbreviate("", max_length: 28)).to be_nil
      end
    end

    context "when text is within the max_length" do
      it "returns the original text without abbreviating" do
        expect(described_class.abbreviate("12 Boulevard Victor", max_length: 28)).to eq("12 Boulevard Victor")
      end

      it "does not abbreviate even if abbreviatable words are present" do
        expect(described_class.abbreviate("Résidence A", max_length: 28)).to eq("Résidence A")
      end
    end

    context "when text exceeds max_length and contains abbreviatable words" do
      it "abbreviates Boulevard to Bvd" do
        expect(described_class.abbreviate("12 Boulevard de la République", max_length: 28))
          .to eq("12 Bvd de la République")
      end

      it "abbreviates Appartement to Apt" do
        expect(described_class.abbreviate("Appartement 5 de la rue longue", max_length: 28))
          .to eq("Apt 5 de la rue longue")
      end

      it "abbreviates Numéro to Num" do
        expect(described_class.abbreviate("Numéro 42 de la rue principale", max_length: 28))
          .to eq("Num 42 de la rue principale")
      end

      it "abbreviates Place to Plc" do
        expect(described_class.abbreviate("Place de la Victoire Extraordinaire", max_length: 28))
          .to eq("Plc de la Victoire Extraordinaire")
      end

      it "abbreviates Chemin to Ch" do
        expect(described_class.abbreviate("Chemin des Écoliers et des Aventuriers", max_length: 28))
          .to eq("Ch des Écoliers et des Aventuriers")
      end

      it "abbreviates Impasse to Imp" do
        expect(described_class.abbreviate("Impasse du Moulin de la Grande Rue", max_length: 28))
          .to eq("Imp du Moulin de la Grande Rue")
      end

      it "abbreviates Résidence to Rdce" do
        expect(described_class.abbreviate("Résidence Les Oliviers de la Provence", max_length: 28))
          .to eq("Rdce Les Oliviers de la Provence")
      end

      it "abbreviates multiple words in the same string" do
        expect(described_class.abbreviate("Résidence Le Parc, Boulevard Victor Hugo, Appartement 12", max_length: 28))
          .to eq("Rdce Le Parc, Bvd Victor Hugo, Apt 12")
      end

      it "is case insensitive" do
        expect(described_class.abbreviate("boulevard de la république française", max_length: 28))
          .to eq("Bvd de la république française")
        expect(described_class.abbreviate("BOULEVARD de la république française", max_length: 28))
          .to eq("Bvd de la république française")
      end

      it "only matches whole words" do
        expect(described_class.abbreviate("Boulevardier de la rue principale", max_length: 28))
          .to eq("Boulevardier de la rue principale")
      end
    end

    context "when abbreviated text is still too long" do
      it "returns the abbreviated text without truncating" do
        result = described_class.abbreviate("12 Boulevard de la République Française Extraordinaire", max_length: 28)
        expect(result).to eq("12 Bvd de la République Française Extraordinaire")
        expect(result.length).to be > 28
      end
    end
  end
end
