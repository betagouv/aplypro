# frozen_string_literal: true

module StudentsApi
  module Sygne
    module Mappers
      class ClasseMapper < Dry::Transformer::Pipe
        import Dry::Transformer::HashTransformations

        define! do
          deep_symbolize_keys

          rename_keys(codeMefRatt: :mef_code, classe: :label)

          map_value(:mef_code, Dry::Transformer::Coercions[:to_string])

          map_value :mef_code, ->(value) { value.chop }

          accept_keys %i[label mef_code]
        end
      end
    end
  end
end
