# frozen_string_literal: true

class Student
  module InfoMappers
    class Sygne < Base
      class Mapper < Dry::Transformer::Pipe
        import Dry::Transformer::HashTransformations

        define! do
          deep_symbolize_keys

          unwrap :adrResidenceEle

          rename_keys(
            codePostal: :address_postal_code,
            adresseLigne1: :address_line1,
            adresseLigne2: :address_line2,
            codePays: :address_country_code,
            codeCommuneInsee: :address_city_insee_code,
            libelleCommune: :address_city,
            inseeCommuneNaissance: :birthplace_city_insee_code,
            inseePaysNaissance: :birthplace_country_insee_code
          )

          accept_keys %i[
            address_postal_code
            address_country_code
            address_city
            address_city_insee_code
            address_line1
            address_line2
            birthplace_city_insee_code
            birthplace_country_insee_code
          ]
        end
      end
    end
  end
end
