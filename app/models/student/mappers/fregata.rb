# frozen_string_literal: true

class Student
  module Mappers
    class Fregata < Base
      FREGATA_MAPPING = {
        ine: "apprenant.ine",
        first_name: "apprenant.prenomUsuel",
        last_name: "apprenant.nomUsuel",
        birthdate: "apprenant.dateNaissance"
      }.freeze

      def map_student_attributes(attrs)
        FREGATA_MAPPING.transform_values do |path|
          attrs.dig(*path.split("."))
        end
      end

      def classes_with_students
        payload
          .group_by { |item| [item["division"]["libelle"], item["sectionReference"]["codeMef"]] }
          .map do |attributes, students|
          label, code = attributes

          mef = Mef.find_by(code: chop_mef_code(code))

          next if mef.nil?

          klass = Classe.find_or_create_by!(
            establishment:,
            mef:,
            label:,
            start_year: @year
          )

          [klass, students]
        end.compact
      end

      def no_class_for_entry?(entry)
        entry["division"].blank?
      end
    end
  end
end
