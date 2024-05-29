# frozen_string_literal: true

module StudentsApi
  module Sygne
    module Mappers
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
            codeUai: :uai,
            anneeScolaire: :school_year,
            dateDebSco: :start_date,
            dateFinSco: :end_date
          )

          map_value(:mef_code, Dry::Transformer::Coercions[:to_string])

          map_value(:annee_scolaire, Dry::Transformer::Coercions[:to_string])

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

          accept_keys %i[ine mef_code label status uai start_date end_date school_year]
        end
      end
    end
  end
end
