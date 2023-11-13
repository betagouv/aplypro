# frozen_string_literal: true

class Student
  module AddressMappers
    class Fregata < Base
      ADDRESS_MAPPING = {
        postal_code: "communeCodePostal",
        country_code: "paysCodeInsee",
        city_insee_code: "communeCodeInsee"
      }.freeze

      def address_attributes
        address = find_relevant_address["adresseIndividu"]

        ADDRESS_MAPPING.transform_values do |path|
          address.dig(*path.split("."))
        end.merge!({ address_line1: scrape_address_lines(address) })
      end

      private

      def find_relevant_address
        payload["adressesApprenant"].find { |entry| entry["estPrioritaire"] == true }
      end

      def scrape_address_lines(address_entry)
        (2..6).map { |index| address_entry["ligne#{index}"] }.compact.join(" ")
      end
    end
  end
end
