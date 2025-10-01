# frozen_string_literal: true

module DataEducationApi
  class EstablishmentApi < DataEducationApi::Base
    class << self
      def dataset
        "fr-en-annuaire-education"
      end

      def result(uai)
        data = fetch!(uai)["results"]

        if data.many?
          data = data.select { |e| e["voie_professionnelle"] == "1" }

          raise "there are more than one establishment returned by the API" if data.many?
        end

        data.first
      end

      private

      def fetch!(uai)
        response = client.get("records") do |req|
          req.params["refine"] = "identifiant_de_l_etablissement:#{uai}"
        end

        response.body
      end
    end
  end
end
