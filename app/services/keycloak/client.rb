# frozen_string_literal: true

module Keycloak
  class Client
    attr_reader :url, :username, :password

    def initialize(url:, username:, password:)
      @url = url.chomp('/')
      @username = username
      @password = password
      @token = nil
    end

    def list_realms
      response = authenticated_request do |conn|
        conn.get('/admin/realms')
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

      conn.headers['Authorization'] = "Bearer #{access_token}"
      yield(conn)
    end

    def access_token
      return @token if @token && !token_expired?

      conn = Faraday.new(url: @url) do |f|
        f.request :url_encoded
        f.response :json
        f.adapter Faraday.default_adapter
      end

      response = conn.post(
        "/realms/master/protocol/openid-connect/token",
        {
          grant_type: 'password',
          client_id: 'admin-cli',
          username: @username,
          password: @password
        }
      )

      if response.success?
        token_data = response.body
        @token = token_data['access_token']
        @token_expiry = Time.now + token_data['expires_in'].to_i
        @token
      else
        raise "Failed to obtain access token: #{response.status} - #{response.body}"
      end
    end

    def token_expired?
      @token_expiry.nil? || Time.now >= @token_expiry
    end
  end
end
