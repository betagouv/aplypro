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

          rename_keys(codeMefRatt: :mef_code, classe: :label)

          map_value(:mef_code, Dry::Transformer::Coercions[:to_string])

          map_value :mef_code, ->(value) { value.chop }

          accept_keys %i[label mef_code]
        end
      end

      def map_schooling!(classe, student, _entry)
        schooling = Schooling.find_or_initialize_by(classe: classe, student: student)

        student.close_current_schooling! if schooling != student.current_schooling

        # we might have an existing closed schooling which needs to be re-opened
        schooling.reopen! if schooling.closed?

        schooling.save!
      end
    end
  end
end
