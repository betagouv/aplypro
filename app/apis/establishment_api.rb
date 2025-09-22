# frozen_string_literal: true

class EstablishmentApi
  DATASET = "fr-en-annuaire-education"

  class << self
    def fetch!(uai)
      response = connection.get("records") do |req|
        req.params["refine"] = "identifiant_de_l_etablissement:#{uai}"
      end

      response.body
    end

    private

    def connection
      Faraday.new(
        url: url,
        headers: { "Content-Type" => "application/json" }
      ) do |f|
        f.response :json
      end
    end

    def url
      "#{ENV.fetch('APLYPRO_DATA_EDUCATION_URL')}/#{DATASET}"
    end
  end
end
