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
        student_attrs = self.class::StudentMapper.new.call(attrs)
        address_attrs = Student::AddressMappers::Fregata.new(attrs).address_attributes

        student_attrs.merge(address_attrs)
      end

      def student_is_gone?(entry)
        left_establishment?(entry)
      end

      def left_establishment?(entry)
        left_at = entry["dateSortieEtablissement"]

        Date.parse(left_at).past? if left_at.present?
      end
    end
  end
end
