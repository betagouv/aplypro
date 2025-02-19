# frozen_string_literal: true

module StudentsApi
  module Fregata
    module Mappers
      class AddressMapper < Dry::Transformer::Pipe
        import Dry::Transformer::HashTransformations
        import Dry::Transformer::ArrayTransformations

        define! do
          find_address

          deep_symbolize_keys

          unwrap :adresseIndividu

          rename_keys(
            communeCodePostal: :address_postal_code,
            paysCodeInsee: :address_country_code,
            communeCodeInsee: :address_city_insee_code
          )

          nest :address_line1, %i[ligne2 ligne3 ligne4 ligne5 ligne6 ligne7]

          map_value :address_line1, ->(hash) { hash.values.compact.join(" | ") }

          accept_keys %i[
            address_postal_code
            address_country_code
            address_city_insee_code
            address_line1
          ]

          catch_empty_address
        end

        def find_address(data)
          addresses = data.dig("apprenant", "adressesApprenant")

          return {} if addresses.blank?

          addresses.find { |entry| entry["estPrioritaire"] == true }
        end

        def catch_empty_address(mapped)
          return {} if mapped.values.all?(&:blank?)

          mapped
        end
      end
    end
  end
end
