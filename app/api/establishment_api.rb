# frozen_string_literal: true

class EstablishmentApi
  DATASET = "fr-en-annuaire-education"

  class << self
    def fetch!(uai)
      response = connection.get("search") do |req|
        req.params["refine.identifiant_de_l_etablissement"] = uai
      end

      JSON.parse(response.body)
    end

    private

    def connection
      Faraday.new(
        url: url,
        params: { dataset: DATASET },
        headers: { "Content-Type" => "application/json" }
      )
    end

    def url
      ENV.fetch("APLYPRO_ESTABLISHMENTS_DATA_URL")
    end
  end
end
