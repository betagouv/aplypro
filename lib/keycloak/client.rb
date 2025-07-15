# frozen_string_literal: true

module Keycloak
  class Client
    KEYCLOAK_HOST = ENV.fetch("KEYCLOAK_HOST")
    KEYCLOAK_ADMIN = ENV.fetch("KEYCLOAK_ADMIN")
    KEYCLOAK_ADMIN_PASSWORD = ENV.fetch("KEYCLOAK_ADMIN_PASSWORD")
    KEYCLOAK_GRANT_TYPE = "password"

    attr_reader :access_token, :connection

    def initialize
      @access_token = authenticate
      @connection = build_connection
    end

    def authenticate
      response = auth_connection.post("token", auth_form_params)
      JSON.parse(response.body)["access_token"]
    end

    def auth_connection
      Faraday.new(
        url: "#{KEYCLOAK_HOST}/realms/master/protocol/openid-connect",
        headers: auth_headers
      )
    end

    def build_connection
      Faraday.new(
        url: "#{KEYCLOAK_HOST}/admin",
        headers: headers
      ) do |conn|
        conn.request :json
        conn.response :json
      end
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

    def auth_form_params
      {
        grant_type: KEYCLOAK_GRANT_TYPE,
        client_id: "admin-cli",
        username: KEYCLOAK_ADMIN,
        password: KEYCLOAK_ADMIN_PASSWORD
      }
    end

    def list_realms
      response = connection.get("realms")
      response.body
    end
  end
end
