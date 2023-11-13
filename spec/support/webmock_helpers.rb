# frozen_string_literal: true

module WebmockHelpers
  class << self
    DEFAULT_TOKEN = JSON.generate({ access_token: "foobar", token_type: "Bearer" })
    def mock_sygne_token_with(payload = DEFAULT_TOKEN)
      WebMock.stub_request(:post, ENV.fetch("APLYPRO_SYGNE_TOKEN_URL"))
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

    def mock_sygne_student_endpoint_with(ine, payload)
      WebMock.stub_request(:get, %r{#{ENV.fetch('APLYPRO_SYGNE_URL')}eleves/#{ine}})
             .with(
               headers: {
                 "Accept" => "*/*",
                 "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
                 "Authorization" => "Bearer foobar",
                 "User-Agent" => "Rack::OAuth2::AccessToken::Bearer (2.2.0)"
               }
             )
             .to_return(status: 200, body: payload, headers: { "Content-Type" => "application/json" })
    end

    def mock_sygne_students_endpoint_with(uai, payload)
      url = StudentApi::Sygne.new(Establishment.new(uai: uai)).endpoint

      WebMock.stub_request(:get, url)
             .with(
               headers: {
                 "Accept" => "*/*",
                 "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
                 "Authorization" => "Bearer foobar",
                 "User-Agent" => "Rack::OAuth2::AccessToken::Bearer (2.2.0)"
               }
             )
             .to_return(status: 200, body: payload, headers: { "Content-Type" => "application/json" })
    end

    def mock_fregata_students_with(uai, payload)
      url = StudentApi::Fregata.new(Establishment.new(uai: uai)).endpoint

      WebMock.stub_request(:get, /#{url}/)
             .with(
               headers: {
                 "Accept" => "*/*",
                 "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3"
               }
             )
             .to_return(status: 200, body: payload, headers: { "Content-Type" => "application/json" })
    end
  end
end
