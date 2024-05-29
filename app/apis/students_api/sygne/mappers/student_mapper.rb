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
            dateNaissance: :birthdate
          )

          accept_keys %i[ine first_name last_name birthdate]
        end
      end
    end
  end
end
