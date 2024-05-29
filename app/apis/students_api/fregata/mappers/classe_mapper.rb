# frozen_string_literal: true

module StudentsApi
  module Fregata
    module Mappers
      class ClasseMapper < Dry::Transformer::Pipe
        import Dry::Transformer::HashTransformations

        define! do
          deep_symbolize_keys

          unwrap :sectionReference
          unwrap :division

          rename_keys(codeMef: :mef_code, libelle: :label)

          map_value :mef_code, ->(value) { value.chop }

          accept_keys %i[label mef_code]
        end
      end
    end
  end
end
