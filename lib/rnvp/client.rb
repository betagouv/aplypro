# frozen_string_literal: true

module Rnvp
  class Client
    class << self
      def address(student)
        return nil if student.nil? || !student.lives_in_france?

        response = authenticated_client!.post("address", header) do |req|
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

      def client
        Rack::OAuth2::Client.new(
          identifier: ENV.fetch("APLYPRO_OMOGEN_CLIENT_ID"),
          secret: ENV.fetch("APLYPRO_OMOGEN_CLIENT_SECRET"),
          token_endpoint: ENV.fetch("APLYPRO_OMOGEN_TOKEN_URL")
        )
      end

      def authenticated_client!
        client.access_token!
      end

      def header
        { "client-uuid": ENV.fetch("RNVP_CLIENT_HEADER") }
      end
    end
  end
end
