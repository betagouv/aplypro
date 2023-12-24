# frozen_string_literal: true

require "webmock/cucumber"

require_relative "../../spec/support/webmock_helpers"

Before do
  extend WebmockHelpers

  etab_fixture = Rails.root.join("mock/data/etab.json").read
  stub_request(:get, /#{ENV.fetch('APLYPRO_ESTABLISHMENTS_DATA_URL')}/)
    .with(
      headers: {
        "Accept" => "*/*",
        "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
        "Content-Type" => "application/json"
      }
    )
    .to_return_json(body: etab_fixture)
end
