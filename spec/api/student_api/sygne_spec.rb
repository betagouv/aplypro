# frozen_string_literal: true

require "rails_helper"
require "./mock/factories/api_student"

describe StudentApi::Sygne do
  subject(:api) { described_class.new(establishment) }

  let(:establishment) { create(:establishment, :sygne_provider) }
  let(:payload) { JSON.generate({ access_token: "foobar", token_type: "Bearer" }) }
  let(:data) { Rails.root.join("mock/data/sygne-students-for-uai.json").read }
  let(:student_data) { Rails.root.join("mock/data/sygne-student.json").read }

  before do
    stub_request(:get, /#{ENV.fetch('APLYPRO_SYGNE_URL')}eleves/)
      .with(
        headers: {
          "Accept" => "*/*",
          "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
          "Authorization" => "Bearer foobar",
          "User-Agent" => "Rack::OAuth2::AccessToken::Bearer (2.2.0)"
        }
      )
      .to_return(status: 200, body: student_data, headers: { "Content-Type" => "application/json" })

    stub_request(:get, /#{api.endpoint}/)
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

  it "calls the correct endpoint" do
    api.fetch!

    expect(WebMock).to have_requested(:get, %r{etablissements/#{establishment.uai}/eleves})
  end

  describe "fetch_student_data!" do
    let(:student) { create(:student) }

    it "needs to be called with an INE" do
      expect { api.fetch_student_data! }.to raise_error ArgumentError
    end

    it "calls the correct endpoint" do
      api.fetch_student_data!(student.ine)

      expect(WebMock).to have_requested(:get, %r{/eleves/#{student.ine}})
    end

    it "returns the parsed data" do
      response = api.fetch_student_data!(student.ine)

      expect(response).to be_a Hash
    end
  end
end
