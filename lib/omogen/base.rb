# frozen_string_literal: true

module Omogen
  class Base
    attr_reader :resource_connection, :access_token

    def initialize
      @access_token = JSON.parse(auth_connection.post("token", auth_params).body)["access_token"]
      @resource_connection = connection
    end

    private

    def base_url
      raise NotImplementedError
    end

    def headers
      {
        "Authorization" => "Bearer #{access_token}",
        "Content-Type" => "application/json"
      }
    end

    def connection
      Faraday.new(
        url: base_url,
        headers: headers
      ) do |f|
        f.request :json
      end
    end

    def auth_url
      raise NotImplementedError
    end

    def auth_params
      raise NotImplementedError
    end

    def auth_connection
      Faraday.new(
        url: auth_url,
        headers: { "Content-Type" => "application/x-www-form-urlencoded" }
      )
    end
  end
end
