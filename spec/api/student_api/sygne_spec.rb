# frozen_string_literal: true

require "rails_helper"
require "./mock/factories/api_student"

describe StudentApi::Sygne do
  subject(:api) { described_class.new(establishment) }

  let(:establishment) { create(:establishment, :with_fim_principal) }
  let(:payload) { JSON.generate({ access_token: "foobar", token_type: "Bearer" }) }
  let(:data) { Rails.root.join("mock/data/sygne-students-for-uai.json").read }

  before do
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

  describe "parsing" do
    context "when the mef code is right" do
      let!(:mefs) { Mef.all.sample(10).map(&:code) }
      let(:data) { mefs.map { |code| FactoryBot.build(:sygne_student, mef: code) } }

      it "records the students" do
        expect { api.fetch_and_parse! }.to change(Student, :count).by(10)
      end

      it "upserts the students" do
        api.fetch_and_parse!

        expect { api.fetch_and_parse! }.not_to change(Student, :count)
      end
    end
  end
end
