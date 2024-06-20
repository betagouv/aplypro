# frozen_string_literal: true

module StudentsApi
  module CSV
    module Mappers
      class ClasseMapper < Dry::Transformer::Pipe
        import Dry::Transformer::HashTransformations

        define! do
          deep_symbolize_keys

          rename_keys(label_classe: :label, année_scolaire: :year)

          accept_keys %i[label mef_code year]
        end
      end
    end
  end
end
