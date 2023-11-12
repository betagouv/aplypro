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

        student_attrs.merge!(address_attrs) if address_attrs.present?

        student_attrs
      end

      def student_has_changed_class?(entry)
        timestamp_past?(entry["dateSortieFormation"])
      end

      def student_has_left_establishment?(entry)
        timestamp_past?(entry["dateSortieEtablissement"])
      end

      private

      def timestamp_past?(value)
        value.present? && Date.parse(value).past?
      end
    end
  end
end
