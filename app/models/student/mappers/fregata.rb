# frozen_string_literal: true

class Student
  module Mappers
    class Fregata < Base
      STUDENT_MAPPING = {
        ine: "apprenant.ine",
        first_name: "apprenant.prenomUsuel",
        last_name: "apprenant.nomUsuel",
        birthdate: "apprenant.dateNaissance"
      }.freeze

      def classe_label(entry)
        entry["division"]["libelle"]
      end

      def classe_mef_code(entry)
        entry["sectionReference"]["codeMef"]
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
