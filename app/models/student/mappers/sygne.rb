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

      def classe_label(entry)
        entry["classe"]
      end

      def classe_mef_code(entry)
        entry["codeMef"]
      end

      def student_has_changed_class?(entry)
        entry["classe"].blank?
      end

      def student_has_left_establishment?(_entry)
        false
      end
    end
  end
end
