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
          unwrap :sectionReference
          unwrap :division

          rename_keys(
            libelle: :label,
            code: :status,
            codeMef: :mef_code,
            codeUai: :uai,
            anneeScolaireId: :school_year,
            dateEntreeFormation: :start_date
          )

          nest :end_date, %i[dateSortieFormation dateSortieEtablissement]

          map_value :end_date, ->(hash) { hash[:dateSortieFormation] || hash[:dateSortieEtablissement] }

          # Seul le MAPPING "2501" est encore utilisé, les autres statuts ne sont plus retournés par FREGATA
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

          map_value :school_year, ->(value) { value + StudentsApi::Fregata::Api::YEAR_OFFSET }

          map_value :mef_code, ->(value) { value.chop }

          accept_keys %i[mef_code label status uai start_date end_date school_year]
        end
      end
    end
  end
end
