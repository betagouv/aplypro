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
            adresseLigne1: :address_line1,
            adresseLigne2: :address_line2,
            adresseLigne3: :address_line3,
            adresseLigne4: :address_line4,
            codePays: :address_country_code,
            codeCommuneInsee: :address_city_insee_code,
            libelleCommune: :address_city,
            inseeCommuneNaissance: :birthplace_city_insee_code,
            inseePaysNaissance: :birthplace_country_insee_code
          )

          address

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

        def address(data)
          data.tap do
            data[:address_line1] = if data[:address_line1].nil?
                                     data[:address_line2]
                                   else
                                     "#{data[:address_line1]} #{data[:address_line2]}" unless data[:address_line2].nil?
                                   end

            data[:address_line2] = if data[:address_line3].nil?
                                     data[:address_line4]
                                   elsif data[:address_line4].nil?
                                     data[:address_line3]
                                   else
                                     "#{data[:address_line3]} #{data[:address_line4]}"
                                   end
          end
        end
      end
    end
  end
end
