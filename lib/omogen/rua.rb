# frozen_string_literal: true

module Omogen
  class Rua < Omogen::Base
    DIR_EMPLOI_TYPE = "D0010"

    def agent_info(email)
      JSON.parse(resource_connection.get("agents", { email: email }).body)
    end

    def synthese_info(email)
      JSON.parse(resource_connection.get("syntheses", { email: email }).body)
    end

    def dirs_for_uai(uai)
      JSON.parse(resource_connection.get("syntheses", { etablissement: uai,
                                                        specialite_emploi_type: DIR_EMPLOI_TYPE }).body)
    end

    private

    def base_url
      ENV.fetch("RUA_RESOURCE_BASE_URL")
    end

    def auth_url
      ENV.fetch("RUA_OMOGEN_TOKEN_URL")
    end

    def auth_params
      {
        grant_type: ENV.fetch("RUA_OMOGEN_GRANT_TYPE"),
        client_id: ENV.fetch("RUA_OMOGEN_CLIENT_ID"),
        client_secret: ENV.fetch("RUA_OMOGEN_CLIENT_SECRET")
      }
    end
  end
end
