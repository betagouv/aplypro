# frozen_string_literal: true

module Keycloak
  class Client
    KEYCLOAK_GRANT_TYPE = "password"

    def keycloak_host
      ENV.fetch("KEYCLOAK_HOST")
    end

    def keycloak_admin
      ENV.fetch("KEYCLOAK_ADMIN")
    end

    def keycloak_admin_password
      ENV.fetch("KEYCLOAK_ADMIN_PASSWORD")
    end

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
        url: "#{keycloak_host}/realms/master/protocol/openid-connect",
        headers: auth_headers
      )
    end

    def build_connection
      Faraday.new(
        url: "#{keycloak_host}/admin",
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
        username: keycloak_admin,
        password: keycloak_admin_password
      }
    end

    def list_realms
      response = connection.get("realms")
      response.body
    end

    def delete_user(realm_name, user_id)
      response = connection.delete("realms/#{realm_name}/users/#{user_id}")
      response.body
    end

    def find_user_by_email(realm_name, email)
      response = connection.get("realms/#{realm_name}/users", { email: email })
      return nil unless response.success?

      users = response.body
      users.is_a?(Array) && users.any? ? users.first : nil
    end

    def remove_user_by_email(realm_name, email)
      user = find_user_by_email(realm_name, email)
      return failure_result("User not found") unless user

      response = connection.delete("realms/#{realm_name}/users/#{user['id']}")
      response.success? ? success_result : failure_result("Failed to remove user: #{response.body}")
    end

    private

    def success_result
      { success: true, message: "User removed successfully" }
    end

    def failure_result(error)
      { success: false, error: error }
    end
  end
end
