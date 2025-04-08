# frozen_string_literal: true

module Rua
  class Client
    DIR_EMPLOI_TYPE = "D0010"

    RUA_KC_URL = ENV.fetch("RUA_KC_URL")
    RUA_KC_GRANT_TYPE = "client_credentials"
    RUA_KC_CLIENT_ID = ENV.fetch("RUA_KC_CLIENT_ID")
    RUA_RESOURCE_BASE_URL = ENV.fetch("RUA_RESOURCE_BASE_URL")
    RUA_KC_CLIENT_SECRET = ENV.fetch("RUA_KC_CLIENT_SECRET")

    attr_reader :resource_connection, :access_token

    def initialize
      @access_token = JSON.parse(auth_connection.post("token", kc_form_params).body)["access_token"]
      @resource_connection = connection
    end

    def agent_info(email)
      JSON.parse(resource_connection.get("agents", { email: email }).body)
    end

    def synthese_info(email)
      JSON.parse(resource_connection.get("syntheses", { email: email }).body)
    end

    def dirs_for_uai(uai)
      JSON.parse(resource_connection.get("syntheses",
                                         { etablissement: uai, specialite_emploi_type: DIR_EMPLOI_TYPE }).body)
    end

    def auth_connection
      Faraday.new(
        url: RUA_KC_URL,
        headers: auth_headers
      )
    end

    def connection
      Faraday.new(
        url: RUA_RESOURCE_BASE_URL,
        params: {},
        headers: headers
      )
    end

    def auth_headers
      { "Content-Type" => "application/x-www-form-urlencoded" }
    end

    def headers
      {
        "Authorization" => "Bearer #{access_token}",
        "Content-Type" => "application/json"
      }
    end

    def kc_form_params
      {
        grant_type: RUA_KC_GRANT_TYPE,
        client_id: RUA_KC_CLIENT_ID,
        client_secret: RUA_KC_CLIENT_SECRET
      }
    end
  end
end
