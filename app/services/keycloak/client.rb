# frozen_string_literal: true

module Keycloak
  class Client
    attr_reader :url, :username, :password

    def initialize(url:, username:, password:)
      @url = url.chomp("/")
      @username = username
      @password = password
      @token = nil
    end

    def list_realms
      response = authenticated_request do |conn|
        conn.get("/admin/realms")
      end

      return [] unless response.success?
      return [] if response.body.nil?

      response.body.is_a?(Array) ? response.body : JSON.parse(response.body)
    rescue JSON::ParserError, Faraday::Error => e
      Rails.logger.error("Failed to fetch realms: #{e.message}")
      []
    end

    private

    def authenticated_request
      conn = Faraday.new(url: @url) do |f|
        f.request :json
        f.response :json, content_type: /\bjson$/
        f.adapter Faraday.default_adapter
      end

      conn.headers["Authorization"] = "Bearer #{access_token}"
      yield(conn)
    end

    def access_token
      return @token if @token && !token_expired?

      token_data = fetch_new_token
      update_token_data(token_data)
      @token
    end

    def fetch_new_token
      response = token_connection.post(
        "/realms/master/protocol/openid-connect/token",
        token_request_params
      )

      raise "Failed to obtain access token: #{response.status} - #{response.body}" unless response.success?

      response.body
    end

    def token_connection
      Faraday.new(url: @url) do |f|
        f.request :url_encoded
        f.response :json
        f.adapter Faraday.default_adapter
      end
    end

    def token_request_params
      {
        grant_type: "password",
        client_id: "admin-cli",
        username: @username,
        password: @password
      }
    end

    def update_token_data(token_data)
      @token = token_data["access_token"]
      @token_expiry = Time.zone.now + token_data["expires_in"].to_i
    end

    def token_expired?
      @token_expiry.nil? || Time.zone.now >= @token_expiry
    end
  end
end
