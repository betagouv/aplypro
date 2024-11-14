# frozen_string_literal: true

module StudentsApi
  module Sygne
    class Api < StudentsApi::Base
      class << self
        def establishment_students_endpoint(params)
          query = { statut: "ST", "annee-scolaire": params[:school_year], "etat-scolarisation": true }.to_query

          base_url + format("etablissements/%s/eleves?#{query}", params[:uai])
        end

        def student_endpoint(params)
          base_url + format("eleves/%s", params[:ine])
        end

        def student_schoolings_endpoint(params)
          base_url + format("eleves/%s/scolarites", params[:ine])
        end

        def get(url)
          authenticated_client!.get(url).body
        end

        private

        def fetch_student_schoolings(params)
          data = super

          data["scolarites"]
        end

        def client
          Rack::OAuth2::Client.new(
            identifier: ENV.fetch("APLYPRO_SYGNE_CLIENT_ID"),
            secret: ENV.fetch("APLYPRO_SYGNE_SECRET"),
            token_endpoint: ENV.fetch("APLYPRO_SYGNE_TOKEN_URL")
          )
        end

        def authenticated_client!
          client.access_token!
        end
      end
    end
  end
end
