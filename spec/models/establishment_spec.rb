require 'rails_helper'
require 'csv'

RSpec.describe Establishment, type: :model do
  subject { FactoryBot.build(:establishment) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:uai) }
  it { is_expected.to validate_uniqueness_of(:uai) }

  describe ".from_csv" do
    subject(:parsed) { Establishment.from_csv(csv) }
    let(:csv) do
      CSV
        .read("spec/fixtures/fr-en-adresse-et-geolocalisation-etablissements-premier-et-second-degre.csv", col_sep: ';', headers: true)
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
        subject.update!(nature: "100")
      end

      it { is_expected.not_to be_second_degree }
    end

    describe "when the UAI nature is a 3xx number" do
      before do
        subject.update!(nature: "301")
      end

      it { is_expected.to be_second_degree }
    end
  end
end
