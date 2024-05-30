# frozen_string_literal: true

module StudentsApi
  module Sygne
    module Mappers
      class StudentMapper < Dry::Transformer::Pipe
        import Dry::Transformer::HashTransformations

        define! do
          symbolize_keys

          rename_keys(
            prenom: :first_name,
            nom: :last_name,
            dateNaissance: :birthdate,
            codeSexe: :biological_sex
          )

          map_value :biological_sex, ->(x) { x == "2" ? :female : :male }

          accept_keys %i[ine first_name last_name birthdate biological_sex]
        end
      end
    end
  end
end
