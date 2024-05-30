# frozen_string_literal: true

module StudentsApi
  module Fregata
    module Mappers
      class StudentMapper < Dry::Transformer::Pipe
        import Dry::Transformer::HashTransformations

        define! do
          deep_symbolize_keys

          unwrap :apprenant

          rename_keys(
            prenomUsuel: :first_name,
            nomUsuel: :last_name,
            dateNaissance: :birthdate,
            communeCodeInsee: :birthplace_city_insee_code,
            paysCodeInsee: :birthplace_country_insee_code,
            sexeId: :biological_sex
          )

          map_value :biological_sex, ->(x) { x.to_i }

          accept_keys %i[
            ine
            first_name
            last_name
            birthdate
            birthplace_city_insee_code
            birthplace_country_insee_code
            biological_sex
          ]
        end
      end
    end
  end
end
