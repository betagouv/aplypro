# frozen_string_literal: true

require "rails_helper"
require "csv"

RSpec.describe Establishment do
  subject(:etab) { build(:establishment, :with_fim_principal) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:uai) }
  it { is_expected.to validate_uniqueness_of(:uai) }

  describe ".from_csv" do
    subject(:parsed) { described_class.from_csv(csv) }

    let(:csv) do
      CSV
        .read(
          "mock/data/fr-en-adresse-et-geolocalisation-etablissements-premier-et-second-degre.csv",
          col_sep: ";",
          headers: true
        )
        .first
    end

    Establishment::CSV_MAPPING.each do |col, attr|
      it "parses the `#{col}` column into the `#{attr}` attribute" do
        expect(parsed[attr]).to(eq csv[col])
      end
    end
  end

  describe "#second_degree?" do
    describe "when the nature isn't a 3xx number" do
      before do
        etab.update!(nature: "100")
      end

      it { is_expected.not_to be_second_degree }
    end

    describe "when the UAI nature is a 3xx number" do
      before do
        etab.update!(nature: "301")
      end

      it { is_expected.to be_second_degree }
    end
  end

  describe "principal connection" do
    it "knows it's got a principal" do
      expect(etab.principal).not_to be_nil
    end
  end
end
