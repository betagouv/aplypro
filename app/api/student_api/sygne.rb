# frozen_string_literal: true

module StudentApi
  class Sygne < Base
    def endpoint
      base_url + format("etablissements/%s/eleves/", @establishment.uai)
    end

    def fetch!
      with_token = client.access_token!

      with_token.get(endpoint).body
    end

    def client
      Rack::OAuth2::Client.new(
        identifier: ENV.fetch("APLYPRO_SYGNE_CLIENT_ID"),
        secret: ENV.fetch("APLYPRO_SYGNE_SECRET"),
        token_endpoint: ENV.fetch("APLYPRO_SYGNE_TOKEN_URL")
      )
    end
  end
end
