# frozen_string_literal: true

class Student
  module AddressMappers
    class Fregata < Base
      def address_attributes
        return nil if addresses.blank?

        Mapper.new.call(principal_address)
      end

      def principal_address
        addresses.find { |e| e["estPrioritaire"] == true }
      end

      def addresses
        payload.dig("apprenant", "adressesApprenant")
      end

      class Mapper < Dry::Transformer::Pipe
        import Dry::Transformer::HashTransformations
        import Dry::Transformer::ArrayTransformations

        define! do
          deep_symbolize_keys

          unwrap :adresseIndividu

          rename_keys(
            communeCodePostal: :address_postal_code,
            paysCodeInsee: :address_country_code,
            communeCodeInsee: :address_city_insee_code
          )

          nest :address_line1, %i[ligne2 ligne3 ligne4 ligne5 ligne6 ligne7]

          map_value :address_line1, ->(hash) { hash.values.compact.join(" ") }

          accept_keys %i[address_postal_code address_country_code address_city_insee_code address_line1]
        end
      end
    end
  end
end
