# frozen_string_literal: true

require "webmock/cucumber"

Before do
  FactoryBot.create(:mefstat, code: "1111")
  FactoryBot.create(:mefstat, code: "4221")

  url = ENV.fetch "APLYPRO_SYGNE_URL"
  fixture = "sygne-students-for-uai.json"
  data = Rails.root.join("mock/data", fixture).read

  stub_request(:get, url)
    .with(
      headers: {
        "Accept" => "*/*",
        "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
        "User-Agent" => "Ruby"
      }
    )
    .to_return(status: 200, body: data, headers: {})
end
