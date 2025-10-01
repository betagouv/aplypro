# frozen_string_literal: true

module DataEducationApi
  class EstablishmentApi < DataEducationApi::Base
    class << self
      def dataset
        "fr-en-annuaire-education"
      end

      def result(uai)
        data = fetch!(uai)["results"]

        data.first || nil
      end

      private

      def fetch!(uai)
        where_clause = "identifiant_de_l_etablissement=\"#{uai}\" AND voie_professionnelle=\"1\""
        query_params = {
          where: where_clause,
          limit: 10
        }

        response = client.get("records", query_params)

        response.body
      end
    end
  end
end
