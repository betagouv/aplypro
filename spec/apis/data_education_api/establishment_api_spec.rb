# frozen_string_literal: true

require "rails_helper"

describe DataEducationApi::EstablishmentApi do
  let(:uai) { "uai" }
  let(:api) { ENV.fetch("APLYPRO_DATA_EDUCATION_URL") }

  before do
    stub_request(:get, /#{Regexp.escape(api)}/)
      .to_return(
        status: 200,
        body: JSON.generate({}),
        headers: { "Content-Type" => "application/json" }
      )
  end

  it "calls the right endpoint" do
    described_class.send(:fetch!, uai)

    where_param = "identifiant_de_l_etablissement%3D%22#{uai}%22%20AND%20voie_professionnelle%3D%221%22"
    url = "#{api}/fr-en-annuaire-education/records?where=#{where_param}&limit=10"

    expect(WebMock).to have_requested(:get, url)
  end

  describe "#result" do
    subject(:result) { described_class.result("1234") }

    before { allow(described_class).to receive(:fetch!).and_return(JSON.parse(json)) }

    context "when it returns no data" do
      let(:json) { { "results" => [] }.to_json }

      it { is_expected.to be_nil }
    end

    context "when it returns data" do
      let(:json) { { "results" => [{ voie_professionnelle: "1" }] }.to_json }

      it { is_expected.not_to be_nil }
    end
  end
end
