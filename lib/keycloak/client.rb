# frozen_string_literal: true

module Keycloak
  class Client # rubocop:disable Metrics/ClassLength
    KEYCLOAK_GRANT_TYPE = "password"

    def keycloak_host
      @custom_host || ENV.fetch("KEYCLOAK_HOST")
    end

    def keycloak_admin
      @custom_admin || ENV.fetch("KEYCLOAK_ADMIN")
    end

    def keycloak_admin_password
      @custom_password || ENV.fetch("KEYCLOAK_ADMIN_PASSWORD")
    end

    attr_reader :access_token, :connection

    def initialize(host = nil, admin_user = nil, admin_password = nil)
      @custom_host = host&.chomp("/")
      @custom_admin = admin_user
      @custom_password = admin_password
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
      response = connection.get("realms/#{realm_name}/users", { email: email, exact: true })
      return nil unless response.success?

      users = response.body
      users.is_a?(Array) && users.any? ? users.first : nil
    end

    def remove_user_by_email(realm_name, email)
      user = find_user_by_email(realm_name, email)
      return failure_result("User not found") unless user

      response = connection.delete("realms/#{realm_name}/users/#{user['id']}")
      if response.success?
        success_result("User removed successfully")
      else
        failure_result("Failed to remove user: #{response.body}")
      end
    end

    def get_user(realm_name, user_id)
      response = connection.get("realms/#{realm_name}/users/#{user_id}")
      return nil unless response.success?

      response.body
    end

    def update_user(realm_name, user_id, attributes)
      response = connection.put("realms/#{realm_name}/users/#{user_id}", attributes)
      if response.success?
        success_result("User updated successfully")
      else
        failure_result("Failed to update user: #{response.body}")
      end
    end

    def create_user(realm_name, email, attributes = {})
      user_payload = {
        email: email,
        username: email,
        enabled: true,
        emailVerified: false,
        attributes: attributes
      }

      response = connection.post("realms/#{realm_name}/users", user_payload)
      if response.success?
        success_result("User created successfully")
      else
        failure_result("Failed to create user: #{response.body}")
      end
    end

    def add_aplypro_academie_resp_attributes(realm_name, email, academy_codes)
      user = find_user_by_email(realm_name, email)

      if user
        user_details = get_user(realm_name, user["id"])
        return failure_result("Failed to fetch user details") unless user_details

        existing_academy_codes = Array(user_details.dig("attributes", "AplyproAcademieResp")).compact
        updated_academy_codes = (existing_academy_codes + academy_codes).uniq

        updated_attributes = user_details.merge(
          "attributes" => user_details.fetch("attributes", {}).merge(
            "AplyproAcademieResp" => updated_academy_codes
          )
        )

        update_user(realm_name, user["id"], updated_attributes)
      else
        create_user(realm_name, email, { "AplyproAcademieResp" => academy_codes })
      end
    end

    def get(path)
      response = connection.get(path)
      raise "HTTP #{response.status}: #{response.body}" unless response.success?

      response.body
    end

    def post(path, body)
      response = connection.post(path, body)
      raise "HTTP #{response.status}: #{response.body}" unless response.success?

      response.body
    end

    def put(path, body)
      response = connection.put(path, body)
      raise "HTTP #{response.status}: #{response.body}" unless response.success?

      response.body
    end

    def find_client_id(realm_name, client_id)
      clients = get("/admin/realms/#{realm_name}/clients?clientId=#{client_id}")
      clients.first["id"] if clients&.any?
    end

    def find_client_scope_id(realm_name, scope_name)
      scopes = get("/admin/realms/#{realm_name}/client-scopes")
      scope = scopes.find { |s| s["name"] == scope_name }
      scope["id"] if scope
    end

    private

    def success_result(message)
      { success: true, message: message }
    end

    def failure_result(error)
      { success: false, error: error }
    end
  end
end
