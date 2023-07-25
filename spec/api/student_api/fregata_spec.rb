# frozen_string_literal: true

require "rails_helper"

describe StudentApi::Fregata do
  subject(:api) { described_class.new(establishment) }

  let(:establishment) { create(:establishment, :with_masa_principal) }
  let(:payload) { JSON.generate({ access_token: "foobar", token_type: "Bearer" }) }

  before do
    stub_request(:get, /#{api.endpoint}/)
      .to_return(status: 200, body: "", headers: {})
  end

  it "queries the right endpoint with the right parameters" do
    api.fetch!

    expect(WebMock)
      .to have_requested(:get, api.endpoint)
      .with(query: { rne: establishment.uai, anneeScolaireId: StudentApi::Fregata::SCHOOL_YEAR })
  end
end
