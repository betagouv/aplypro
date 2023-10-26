# frozen_string_literal: true

class Student
  module Mappers
    class Sygne < Base
      SYGNE_MAPPING = {
        "prenom" => :first_name,
        "nom" => :last_name,
        "ine" => :ine,
        "dateNaissance" => :birthdate
      }.freeze

      def map_student_attributes(attrs)
        SYGNE_MAPPING.to_h do |attr, col|
          [col, attrs[attr]]
        end
      end

      def classes_with_students
        payload
          .group_by { |entry| [entry["classe"], entry["codeMef"]] }
          .map do |attributes, students|
          label, code = attributes

          mef = Mef.find_by(code: code.slice(..-2))

          next if mef.nil? || label.nil?

          klass = Classe.find_or_create_by!(
            label:,
            mef:,
            establishment: establishment,
            start_year: @year
          )

          [klass, students]
        end.compact
      end

      def no_class_for_entry?(entry)
        entry["classe"].blank?
      end
    end
  end
end
