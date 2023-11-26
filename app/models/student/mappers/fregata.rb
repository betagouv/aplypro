# frozen_string_literal: true

class Student
  module Mappers
    class Fregata < Base
      class StudentMapper < Dry::Transformer::Pipe
        import Dry::Transformer::HashTransformations

        define! do
          deep_symbolize_keys

          unwrap :apprenant

          rename_keys(
            prenomUsuel: :first_name,
            nomUsuel: :last_name,
            dateNaissance: :birthdate
          )

          accept_keys %i[ine first_name last_name birthdate]
        end
      end

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

      def map_student_attributes(attrs)
        student_attrs = super(attrs)

        address_attrs = Student::AddressMappers::Fregata.new(attrs).address_attributes

        student_attrs.merge!(address_attrs) if address_attrs.present?

        student_attrs
      end

      def map_schooling!(classe, student, entry)
        schooling = Schooling.find_or_initialize_by(classe: classe, student: student)

        schooling.end_date = left_classe_at(entry)

        schooling.save!
      end

      def left_classe_at(entry)
        entry["dateSortieFormation"] || entry["dateSortieEtablissement"]
      end
    end
  end
end
