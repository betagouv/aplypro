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

          classe = Classe.find_or_create_by!(
            establishment:,
            mef:,
            label:,
            start_year: @year
          )

          [classe, students]
        end.compact
      end

      def student_is_gone?(entry)
        left_establishment?(entry)
      end

      def left_establishment?(entry)
        left_at = entry["apprenant"]["dateSortieEtablissement"]

        Date.parse(left_at).past? if left_at.present?
      end
    end
  end
end
