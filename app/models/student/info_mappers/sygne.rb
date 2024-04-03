# frozen_string_literal: true

class Student
  module InfoMappers
    class Sygne < Base
      class Mapper < Dry::Transformer::Pipe
        import Dry::Transformer::HashTransformations
        import Dry::Transformer::Coercions

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
            inseePaysNaissance: :birthplace_country_insee_code,
            codeSexe: :biological_sex
          )

          # FIXME: ideally we'd use dry-transformer's `to_integer`
          # function but for the life of me I *cannot* figure out how
          # to chain it in here
          map_value :biological_sex, ->(x) { x.to_i }

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

      class SchoolingMapper < Dry::Transformer::Pipe
        import Dry::Transformer::HashTransformations
        import Dry::Transformer::Coercions

        define! do
          deep_symbolize_keys

          unwrap :scolarite

          rename_keys(
            classe: :label,
            codeStatut: :status,
            codeMefRatt: :mef_code,
            codeUai: :uai
          )

          map_value(:mef_code, Dry::Transformer::Coercions[:to_string])

          map_value :mef_code, ->(value) { value.chop }

          map_value :status, lambda { |value|
            case value
            when "ST"
              :student
            when "AP"
              :apprentice
            when "FQ"
              :other
            else
              raise Student::Mappers::Errors::SchoolingParsingError
            end
          }

          accept_keys %i[ine mef_code label status uai]
        end
      end

      def schooling_finder_attributes
        schooling_attributes
      end
    end
  end
end
