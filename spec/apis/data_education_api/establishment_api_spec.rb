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

    context "when it returns one result" do
      let(:results) { [{ "test" => "1" }] }
      let(:json) { { "results" => results }.to_json }

      it { is_expected.to eq results.first }
    end

    context "when it returns more than one result" do
      let(:results) { [{ "test1" => "1" }, { "test2" => "2" }] }
      let(:json) { { "results" => results }.to_json }

      it { is_expected.to eq results.first }
    end
  end
end
