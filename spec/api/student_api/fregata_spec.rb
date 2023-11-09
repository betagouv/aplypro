# frozen_string_literal: true

require "rails_helper"

describe StudentApi::Fregata do
  subject(:api) { described_class.new(establishment) }

  let(:establishment) { create(:establishment, :with_masa_user) }
  let(:payload) { JSON.generate({ access_token: "foobar", token_type: "Bearer" }) }

  before do
    stub_request(:get, /#{api.endpoint}/)
      .to_return(status: 200, body: "", headers: {})
  end

  it "queries the right endpoint with the right parameters" do
    api.fetch!

    # this will break next year (or whenever we change
    # APLYPRO_SCHOOL_YEAR), which is a great reminder to double-check
    # that everything is updated correctly
    expect(WebMock)
      .to have_requested(:get, api.endpoint)
      .with(query: { rne: establishment.uai, anneeScolaireId: 27 })
  end

  it "calculates the proper year" do
    stub_const("ENV", ENV.to_hash.merge("APLYPRO_SCHOOL_YEAR" => "2040"))

    api.fetch!

    expect(WebMock)
      .to have_requested(:get, api.endpoint)
      .with(query: { rne: establishment.uai, anneeScolaireId: 44 })
  end
end
