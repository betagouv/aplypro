# frozen_string_literal: true

class Student
  module InfoMappers
    class Fregata < Base
      def attributes
        Mapper
          .new
          .call(payload)
          .tap do |attrs|
          attrs.merge!(address_attributes) if address_attributes.present?
        end
      end

      def address_attributes
        return nil if addresses.blank?

        AddressMapper.new.call(principal_address)
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

          unwrap :apprenant

          rename_keys(
            communeCodeInsee: :birthplace_city_insee_code,
            paysCodeInsee: :birthplace_country_insee_code,
            sexeId: :biological_sex
          )

          map_value :biological_sex, ->(x) { x.to_i }

          accept_keys %i[
            birthplace_city_insee_code
            birthplace_country_insee_code
            biological_sex
          ]
        end
      end

      class AddressMapper < Dry::Transformer::Pipe
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

          accept_keys %i[
            address_postal_code
            address_country_code
            address_city_insee_code
            address_line1
          ]
        end
      end

      class SchoolingMapper < Dry::Transformer::Pipe
        import Dry::Transformer::HashTransformations
        import Dry::Transformer::ArrayTransformations

        define! do
          deep_symbolize_keys

          unwrap :statutApprenant
          unwrap :apprenant

          rename_keys(
            code: :status
          )

          map_value :status, lambda { |value|
            case value
            when "2503"
              :apprentice
            when "2501"
              :student
            else
              raise Student::Mappers::Errors::SchoolingParsingError
            end
          }

          accept_keys %i[status ine]
        end
      end

      # FREGATA uses the same endpoint for listing and extra info so
      # we can reuse the other mappers
      def schooling_finder_attributes
        schooling_attributes
          .merge(Student::Mappers::Fregata::ClasseMapper.new.call(payload))
          .merge(uai: uai)
      end
    end
  end
end
