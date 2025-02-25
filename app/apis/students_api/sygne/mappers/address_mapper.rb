# frozen_string_literal: true

module StudentsApi
  module Sygne
    module Mappers
      class AddressMapper < Dry::Transformer::Pipe
        import Dry::Transformer::HashTransformations
        import Dry::Transformer::Coercions

        define! do
          deep_symbolize_keys

          unwrap :adrResidenceEle

          rename_keys(
            codePostal: :address_postal_code,
            codePays: :address_country_code,
            codeCommuneInsee: :address_city_insee_code,
            libelleCommune: :address_city,
            inseeCommuneNaissance: :birthplace_city_insee_code,
            inseePaysNaissance: :birthplace_country_insee_code
          )

          nest :address_line1, %i[adresseLigne1 adresseLigne2]
          nest :address_line2, %i[adresseLigne3 adresseLigne4]

          map_value :address_line1, ->(hash) { hash.values.compact.join(" ") }
          map_value :address_line2, ->(hash) { hash.values.compact.join(" ") }

          accept_keys %i[
            address_postal_code
            address_country_code
            address_city
            address_city_insee_code
            address_line1
            address_line2
            biological_sex
            birthplace_city_insee_code
            birthplace_country_insee_code
          ]
        end
      end
    end
  end
end
