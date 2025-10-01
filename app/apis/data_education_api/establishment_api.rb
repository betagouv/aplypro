# frozen_string_literal: true

module DataEducationApi
  class EstablishmentApi < DataEducationApi::Base
    class << self
      def dataset
        "fr-en-annuaire-education"
      end

      def result(uai)
        fetch!(uai)["results"].first || nil
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
