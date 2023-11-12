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
