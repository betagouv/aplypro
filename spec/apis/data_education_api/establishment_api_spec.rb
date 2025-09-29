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
end
