# frozen_string_literal: true

require "rails_helper"

describe StudentApi::Sygne do
  subject(:api) { described_class.new(establishment) }

  let(:establishment) { create(:establishment, :with_fim_principal) }
  let(:payload) { JSON.generate({ access_token: "foobar", token_type: "Bearer" }) }

  before do
    fixture = "sygne-students-for-uai.json"
    data = Rails.root.join("mock/data", fixture).read
    url = ENV.fetch("APLYPRO_SYGNE_URL") % establishment.uai

    stub_request(:get, url)
      .with(
        headers: {
          "Accept" => "*/*",
          "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3"
        }
      )
      .to_return(status: 200, body: data, headers: { "Content-Type" => "application/json" })

    stub_request(:post, ENV.fetch("APLYPRO_SYGNE_TOKEN_URL"))
      .with(
        body: { "grant_type" => "client_credentials" },
        headers: {
          "Accept" => "*/*",
          "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
          "Content-Type" => "application/x-www-form-urlencoded"
        }
      )
      .to_return(status: 200, body: payload, headers: { "Content-Type" => "application/json" })
  end

  it "grabs an access token before calling the API" do
    api.fetch!

    expect(WebMock).to have_requested(:post, ENV.fetch("APLYPRO_SYGNE_TOKEN_URL"))
  end
end
