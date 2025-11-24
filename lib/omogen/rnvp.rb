# frozen_string_literal: true

module Omogen
  class Rnvp < Omogen::Base
    class << self
      def address(student)
        return nil if student.nil? || !student.lives_in_france?

        response = connection.post(
          "address",
          {
            ligne2: student.address_line1,
            ligne3: student.address_line2,
            codePostal: student.address_postal_code,
            codeInsee: student.address_city_insee_code,
            localite: student.address_city
          }
        )

        response.body
      end

      private

      def base_url
        ENV.fetch("RNVP_RESSOURCE_BASE_URL")
      end

      def headers
        super.merge!("client-uuid" => ENV.fetch("RNVP_CLIENT_HEADER"))
      end
    end
  end
end
