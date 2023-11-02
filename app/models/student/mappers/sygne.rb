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

      def student_is_gone?(entry)
        no_classe_for_entry?(entry)
      end

      def no_classe_for_entry?(entry)
        entry["classe"].blank?
      end
    end
  end
end
