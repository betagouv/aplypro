# frozen_string_literal: true

require "webmock/cucumber"
require "./mock/factories/api_student"

Before do
  stub_request(:get, ENV.fetch("APLYPRO_SYGNE_URL"))
    .with(
      headers: {
        "Accept" => "*/*",
        "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
        "User-Agent" => "Ruby"
      }
    )
    .to_return(status: 200, body: FactoryBot.build_list(:sygne_student, 10), headers: {})

  etab_fixture = Rails.root.join("mock/data/etab.json").read
  stub_request(:get, /#{ENV.fetch('APLYPRO_ESTABLISHMENTS_DATA_URL')}/)
    .with(
      headers: {
        "Accept" => "*/*",
        "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
        "Content-Type" => "application/json",
        "User-Agent" => "Faraday v2.7.10"
      }
    )
    .to_return_json(body: etab_fixture)
end
