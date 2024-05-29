# frozen_string_literal: true

module StudentsApi
  module Sygne
    class Api < StudentsApi::Base
      def endpoint
        base_url + format("etablissements/%s/eleves/", uai)
      end

      def student_endpoint(ine)
        base_url + format("eleves/%s", ine)
      end

      def fetch!
        params = { "etat-scolarisation" => "true" }

        authenticated_client!.get(endpoint, params).body
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
end
