# frozen_string_literal: true

module Rnvp
  class Client
    RNVP_BASE_URL = ENV.fetch("RNVP_BASE_URL")
    RNVP_SECRET = ENV.fetch("RNVP_SECRET")

    attr_reader :resource_connection

    def initialize
      @resource_connection = connection
    end

    def address(student)
      return nil if student.nil? || !student.lives_in_france?

      response = resource_connection.post("address") do |req|
        req.body = {
          ligne2: student.address_line1,
          ligne3: student.address_line2,
          codePostal: student.address_postal_code,
          codeInsee: student.address_city_insee_code,
          localite: student.address_city
        }.to_json
      end

      response.body
    end

    private

    def connection
      Faraday.new(
        url: RNVP_BASE_URL,
        headers: {
          "Content-Type" => "application/json",
          "X-Omogen-Api-Key" => RNVP_SECRET
        }
      ) do |f|
        f.response :json
      end
    end
  end
end
