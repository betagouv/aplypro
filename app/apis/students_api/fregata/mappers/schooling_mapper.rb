# frozen_string_literal: true

module StudentsApi
  module Fregata
    module Mappers
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
    end
  end
end
