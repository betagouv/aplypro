# frozen_string_literal: true

require "rails_helper"

describe DataEducationApi::EstablishmentApi do
  let(:api) { "https://api.com" }
  let(:uai) { "uai" }

  before do
    allow(ENV)
      .to receive(:fetch)
      .with("APLYPRO_DATA_EDUCATION_URL")
      .and_return(api)

    stub_request(:get, /#{api}/)
      .to_return(
        status: 200,
        body: JSON.generate({}),
        headers: { "Content-Type" => "application/json" }
      )
  end

  it "calls the right endpoint" do
    described_class.send(:fetch!, uai)

    url = "#{api}/fr-en-annuaire-education/records?refine=identifiant_de_l_etablissement:#{uai}"

    expect(WebMock).to have_requested(:get, url)
  end

  describe "#result" do
    subject(:result) { described_class.result("1234") }

    before { allow(described_class).to receive(:fetch!).and_return(JSON.parse(json)) }

    context "when it returns no data" do
      let(:json) { { "results" => [] }.to_json }

      it { is_expected.to be_nil }
    end

    context "when the EstablishmentApi more than one result and none of them has 'voie_professionnelle' equal to 1" do
      let(:json) { { "results" => [{ voie_professionnelle: "0" }, { voie_professionnelle: "0" }] }.to_json }

      it { is_expected.to be_nil }
    end

    context "when the EstablishmentApi more than one result and one of them has 'voie_professionnelle' equal to 1" do
      let(:json) { { "results" => [{ voie_professionnelle: "1" }, { voie_professionnelle: "0" }] }.to_json }

      it { is_expected.not_to be_nil }
    end

    context "when the EstablishmentApi more than one result and two of them has 'voie_professionnelle' equal to 1" do
      let(:json) { { "results" => [{ voie_professionnelle: "1" }, { voie_professionnelle: "1" }] }.to_json }

      it "raise an error" do
        expect { result }.to raise_error(/there are more than one establishment/)
      end
    end
  end
end
