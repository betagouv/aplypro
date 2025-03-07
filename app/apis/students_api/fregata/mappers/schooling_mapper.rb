# frozen_string_literal: true

module StudentsApi
  module Fregata
    module Mappers
      class SchoolingMapper < Dry::Transformer::Pipe
        import Dry::Transformer::HashTransformations

        define! do
          deep_symbolize_keys

          unwrap :statutApprenant
          unwrap :apprenant

          rename_keys(
            code: :status,
            dateEntreeFormation: :start_date
          )

          # Seul le MAPPING "2501" est encore utilisé, les autres statuts ne sont plus retournés par SYGNE
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

          accept_keys %i[ine status start_date]
        end
      end
    end
  end
end
