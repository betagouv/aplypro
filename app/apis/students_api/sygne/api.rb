# frozen_string_literal: true

module StudentsApi
  module Sygne
    class Api < StudentsApi::Base
      class << self
        def establishment_students_endpoint(params)
          query = { statut: "ST", "annee-scolaire": params[:start_year] }.to_query

          base_url + format("etablissements/%s/eleves?#{query}", params[:uai])
        end

        def student_endpoint(params)
          base_url + format("eleves/%s", params.fetch(:ine))
        end

        def student_schoolings_endpoint(params)
          base_url + format("eleves/%s/scolarites", params.fetch(:ine))
        end

        def get(url)
          return nil if in_summer_hiatus_range?

          authenticated_client!.get(url).body
        end

        private

        def fetch_student_schoolings(params)
          data = super

          return nil if data.nil?

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

        def in_summer_hiatus_range?
          return false unless ActiveModel::Type::Boolean.new.cast(ENV.fetch("APLYPRO_SYGNE_SUMMER_HIATUS_ENABLED"))

          year = SchoolYear.current.end_year
          range = Date.parse("#{year}-06-01")..Date.parse("#{year}-09-01")

          range.include?(Time.zone.today)
        end
      end
    end
  end
end
