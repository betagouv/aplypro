# frozen_string_literal: true

module DataEducationApi
  class EstablishmentApi < DataEducationApi::Base
    class << self
      def dataset
        "fr-en-annuaire-education"
      end

      def fetch!(uai)
        response = connection.get("records") do |req|
          req.params["refine"] = "identifiant_de_l_etablissement:#{uai}"
        end

        response.body
      end

      private

      def connection
        Faraday.new(
          url: base_url,
          headers: { "Content-Type" => "application/json" }
        ) do |f|
          f.response :json
        end
      end
    end
  end
end
