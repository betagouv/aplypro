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
        payload["apprenant"]["adressesApprenant"]
      end

      class Mapper < Dry::Transformer::Pipe
        import Dry::Transformer::HashTransformations
        import Dry::Transformer::ArrayTransformations

        define! do
          deep_symbolize_keys

          unwrap :adresseIndividu

          rename_keys(
            communeCodePostal: :postal_code,
            paysCodeInsee: :country_code,
            communeCodeInsee: :city_insee_code
          )

          nest :address_line1, %i[ligne2 ligne3 ligne4 ligne5 ligne6 ligne7]

          map_value :address_line1, ->(hash) { hash.values.compact.join(" ") }

          accept_keys %i[postal_code country_code city_insee_code address_line1]
        end
      end
    end
  end
end
