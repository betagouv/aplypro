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
