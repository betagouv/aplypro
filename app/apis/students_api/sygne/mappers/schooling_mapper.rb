# frozen_string_literal: true

module StudentsApi
  module Sygne
    module Mappers
      class SchoolingMapper < Dry::Transformer::Pipe
        STATUS_MAPPING = {
          "ST" => :student,
          "AP" => :apprentice,
          "FQ" => :other
        }.freeze

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

          maybe_fallback_mef

          map_value(:mef_code, Dry::Transformer::Coercions[:to_string])

          map_value(:annee_scolaire, Dry::Transformer::Coercions[:to_string])

          map_value :mef_code, ->(value) { value.chop }

          map_value :status, ->(value) { STATUS_MAPPING[value] }

          accept_keys %i[ine mef_code label status uai start_date end_date school_year]
        end

        def maybe_fallback_mef(data)
          data.tap { data[:mef_code] ||= data[:codeMef] }
        end
      end
    end
  end
end
