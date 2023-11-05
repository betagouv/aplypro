# frozen_string_literal: true

module StudentApi
  class Sygne < Base
    def endpoint
      base_url + format("etablissements/%s/eleves/", @establishment.uai)
    end

    def student_endpoint(ine)
      base_url + format("eleves/%s", ine)
    end

    def fetch!
      authenticated_client!.get(endpoint).body
    end

    def fetch_student_data!(ine)
      authenticated_client!.get(student_endpoint(ine)).body
    end

    def client
      Rack::OAuth2::Client.new(
        identifier: ENV.fetch("APLYPRO_SYGNE_CLIENT_ID"),
        secret: ENV.fetch("APLYPRO_SYGNE_SECRET"),
        token_endpoint: ENV.fetch("APLYPRO_SYGNE_TOKEN_URL")
      )
    end

    private

    def authenticated_client!
      client.access_token!
    end
  end
end
