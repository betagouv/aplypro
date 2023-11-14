# frozen_string_literal: true

class Student
  module Mappers
    class Sygne < Base
      STUDENT_MAPPING = {
        ine: "ine",
        first_name: "prenom",
        last_name: "nom",
        birthdate: "dateNaissance"
      }.freeze

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

      class ClasseMapper < Dry::Transformer::Pipe
        import Dry::Transformer::HashTransformations

        define! do
          deep_symbolize_keys

          rename_keys(codeMef: :mef_code, classe: :label)

          map_value :mef_code, ->(value) { value.chop }

          accept_keys %i[label mef_code]
        end
      end

      def student_is_gone?(entry)
        no_classe_for_entry?(entry)
      end

      def no_classe_for_entry?(entry)
        entry["classe"].blank?
      end
    end
  end
end
